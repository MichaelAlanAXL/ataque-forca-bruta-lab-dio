# Mitigações e Recomendações Práticas contra Ataques de Força Bruta

Este documento reúne medidas práticas que você pode aplicar em aplicações web (PHP) e na infra para reduzir risco de ataques de força bruta. Os exemplos são técnicos e voltados para ambiente de produção — em laboratório use apenas para demonstração.

---

## 1) Boas práticas gerais
- Nunca armazene senhas em texto plano. Use `password_hash()` e `password_verify()` no PHP.
- Use autenticação por chave onde aplicável (SSH) e desabilite autenticação por senha quando possível.
- Habilite MFA (TOTP, SMS, ou hardware token) para contas sensíveis.
- Aplique rate limiting por IP e por conta.
- Centralize logs de autenticação e monitore tentativas suspeitas (SIEM, alertas).
- Minimize exposição de serviços (feche portas e serviços não necessários).

---

## 2) Estruturas de dados úteis

SQL para registrar tentativas de login (exemplo):

```sql
CREATE TABLE login_attempts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(255) NULL,
  ip_address VARCHAR(45) NOT NULL,
  attempt_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  success TINYINT(1) NOT NULL DEFAULT 0
);

CREATE INDEX idx_ip_time ON login_attempts (ip_address, attempt_time);
CREATE INDEX idx_user_time ON login_attempts (username, attempt_time);
```

- Este registro permite contagens por IP ou por usuário em uma janela de tempo.

---

## 3) Exemplo: Bloqueio por IP e por usuário (PHP + PDO)

Descrição: código de exemplo para checar número de tentativas e aplicar bloqueio temporário.

```php
// Configuração: thresholds
define('MAX_ATTEMPTS_IP', 20);
define('MAX_ATTEMPTS_USER', 5);
define('WINDOW_MINUTES', 15);

def check_bruteforce(PDO $pdo, string $ip, ?string $username): array {
    $since = (new DateTime())->modify('-'.WINDOW_MINUTES.' minutes')->format('Y-m-d H:i:s');

    // contar por IP
    $stmt = $pdo->prepare('SELECT COUNT(*) FROM login_attempts WHERE ip_address = ? AND attempt_time >= ?');
    $stmt->execute([$ip, $since]);
    $countIp = (int)$stmt->fetchColumn();

    $countUser = 0;
    if ($username !== null) {
        $stmt = $pdo->prepare('SELECT COUNT(*) FROM login_attempts WHERE username = ? AND attempt_time >= ?');
        $stmt->execute([$username, $since]);
        $countUser = (int)$stmt->fetchColumn();
    }

    return ['countIp' => $countIp, 'countUser' => $countUser];
}

function register_attempt(PDO $pdo, ?string $username, string $ip, bool $success): void {
    $stmt = $pdo->prepare('INSERT INTO login_attempts (username, ip_address, success) VALUES (?, ?, ?)');
    $stmt->execute([$username, $ip, $success ? 1 : 0]);
}

// Uso no fluxo de login
$ip = $_SERVER['REMOTE_ADDR'];
$username = $_POST['username'] ?? null;
$counts = check_bruteforce($pdo, $ip, $username);

if ($counts['countIp'] >= MAX_ATTEMPTS_IP) {
    // Bloqueio por IP
    http_response_code(429);
    echo 'Muitas tentativas a partir do seu IP. Tente novamente mais tarde.';
    exit;
}

if ($counts['countUser'] >= MAX_ATTEMPTS_USER) {
    // Bloqueio por usuário
    http_response_code(429);
    echo 'Conta temporariamente bloqueada devido a tentativas múltiplas.';
    exit;
}

// depois de validar senha com password_verify:
$success = password_verify($password, $hashedPasswordFromDb);
register_attempt($pdo, $username, $ip, $success);

if ($success) {
    // limpar tentativas antigas para o usuário (opcional)
    $stmt = $pdo->prepare('DELETE FROM login_attempts WHERE username = ?');
    $stmt->execute([$username]);
    // login ok
}
```

Notas:
- Para alta taxa de tráfego, use um contador em Redis para performance (exemplo abaixo).

---

## 4) Exemplo: Rate limiting com Redis (contadores por IP)

- Necessita extensão `phpredis` ou `predis`.

```php
// Exemplo simples com phpredis
$redis = new Redis();
$redis->connect('127.0.0.1', 6379);

$ip = $_SERVER['REMOTE_ADDR'];
$key = "login_attempts:ip:$ip";
$window = 900; // segundos (15 minutos)
$max = 100; // limite de requests na janela

$count = $redis->incr($key);
if ($count === 1) {
  $redis->expire($key, $window);
}

if ($count > $max) {
  http_response_code(429);
  echo 'Muitas requisições — tente novamente mais tarde.';
  exit;
}
```

- Para proteção contra bots, limite também por rota específica (ex.: `/login`) e por combinação IP+URI.

---

## 5) Exemplo: Implementação de lockout exponencial (backoff)

```php
// logic pseudo:
// - manter contador por username
// - ao atingir X tentativas, aplicar tempo de lockout que cresce exponencialmente

function get_lockout_seconds(int $failedAttempts): int {
    if ($failedAttempts < 5) return 0;
    // fórmula simples: 2^(failedAttempts - 5) * 60 segundos
    return pow(2, $failedAttempts - 5) * 60;
}

// ao falhar, incrementar contador em DB e checar lockout
```

---

## 6) Integração com Fail2ban (sistema)

- Fail2ban funciona monitorando logs (ex.: `/var/log/auth.log`, logs de Apache/Nginx ou logs da sua app) e aplicando bloqueios no firewall (iptables).

Exemplo de `jail.local` simples para proteger um endpoint de login em um arquivo de log customizado (`/var/log/php_login.log`):

```
[php-login]
enabled = true
filter = php-login
logpath = /var/log/php_login.log
maxretry = 5
findtime = 600
bantime = 3600

# Crie um filtro em /etc/fail2ban/filter.d/php-login.conf para capturar linhas de 'failed login' geradas pela sua aplicação
```

Exemplo de filtro `php-login.conf` (muito simples):

```
[Definition]
failregex = .*Failed login for <HOST>.*
ignoreregex =
```

No seu app PHP, emita linhas de log para `php_login.log` quando houver falhas de autenticação, por exemplo:

```php
error_log("Failed login for $ip user=$username", 3, '/var/log/php_login.log');
```

Fail2ban então bloqueará o IP no nível do host.

---

## 7) Proteção no nível do servidor web (Nginx) — rate limiting

Exemplo de configuração Nginx para limitar requisições por IP:

```
http {
    limit_req_zone $binary_remote_addr zone=one:10m rate=10r/m;

    server {
        location /login {
            limit_req zone=one burst=5 nodelay;
            proxy_pass http://backend;
        }
    }
}
```

- `rate=10r/m` limita a 10 requisições por minuto por IP para a zona definida.

---

## 8) CAPTCHA
- Adicione um CAPTCHA (reCAPTCHA v2/v3) no formulário de login após N tentativas.
- Não mostrado aqui por questões de bibliotecas, mas o fluxo é: servidor valida token do reCAPTCHA antes de aceitar a requisição de login.

Exemplo (pseudo):
```php
// após N falhas
$recaptchaToken = $_POST['g-recaptcha-response'] ?? '';
// verificar token com a API do Google
// se inválido: rejeitar
```

---

## 9) Autenticação multifator (MFA/TOTP) — exemplo básico em PHP

Notas: para TOTP em produção, use bibliotecas testadas (eg. RobThree/TwoFactorAuth, spomky-labs/otphp). Aqui mostramos pseudocódigo/fluxo com placeholders.

1) Gerar segredo e mostrar QR para o usuário (fase de registro):
```php
// gerar segredo (base32)
$secret = '<TWO_FACTOR_SECRET_GENERATED>'; // use library para gerar
// gerar URI otpauth:// e QR code (exibir para usuário com app Authenticator)
$otpauth = "otpauth://totp/SeuApp:{$username}?secret={$secret}&issuer=SeuApp";
// apresentar QR ao usuário (biblioteca para qrcode)
```

2) Verificar token durante login:
```php
// usuário envia token do app (ex: $_POST['token_2fa'])
$token = $_POST['token_2fa'] ?? '';
// verificar token com biblioteca TOTP usando $secret armazenado para o usuário
$valid = verify_totp($secret, $token); // placeholder — use lib
if (! $valid) {
    // rejeitar login
}
```

No relatório, indique que o campo secreto (<TWO_FACTOR_SECRET>) é armazenado no DB e que, na verificação, o servidor compara o token fornecido com o valor esperado naquele tempo.

---

## 10) Armazenamento de senhas e segurança de sessão
- Use `password_hash($password, PASSWORD_DEFAULT)` e `password_verify()` no PHP.
- Use cookies com `HttpOnly`, `Secure` e `SameSite=strict` para sessões.
- Regenerar `session_id()` após login bem-sucedido.

Exemplo rápido:
```php
$hash = password_hash($password, PASSWORD_DEFAULT);
// armazenar $hash no DB

// verificação
if (password_verify($password, $hashFromDb)) {
    session_regenerate_id(true);
    $_SESSION['user_id'] = $userId;
}
```

---

## 11) Monitoramento e alertas
- Centralize logs e configure alertas para padrões:
  - pico de tentativas por IP
  - tentativas em muitas contas distintas vindas de mesmo IP
  - acessos a contas administrativas
- Ferramentas: ELK/EFK, Splunk, Grafana+Prometheus, ou serviços cloud.

---

## 12) Checklist rápido de mitigação
- [ ] Senhas armazenadas com `password_hash`
- [ ] MFA disponível para contas sensíveis
- [ ] Rate limiting no app e no servidor
- [ ] Fail2ban ou bloqueio no firewall configurado
- [ ] Logs de autenticação centralizados e monitorados
- [ ] CAPTCHA após N tentativas
- [ ] Session cookies configurados corretamente

---

> Observação: os trechos de código são exemplos educativos. Para produção, use bibliotecas consolidadas e revise requisitos de performance e escalabilidade.
