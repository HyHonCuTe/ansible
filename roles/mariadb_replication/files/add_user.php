<?php
// Database connection configuration
$db_host = '127.0.0.1';
$db_name = 'webapp_db';
$db_user = 'webapp_user';
$db_pass = 'Admin123@';

// Get actual server hostname
$server_name = gethostname();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'] ?? '';
    $email = $_POST['email'] ?? '';
    
    if (empty($username) || empty($email)) {
        header('Location: index.php?error=empty');
        exit;
    }
    
    try {
        $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        // Insert user
        $stmt = $pdo->prepare("INSERT INTO users (username, email, server_name) VALUES (?, ?, ?)");
        $stmt->execute([$username, $email, $server_name]);
        
        header('Location: index.php?success=1');
        exit;
        
    } catch(PDOException $e) {
        header('Location: index.php?error=' . urlencode($e->getMessage()));
        exit;
    }
} else {
    header('Location: index.php');
    exit;
}
?>
