<?php
// Database connection configuration
$db_host = '127.0.0.1';
$db_name = 'webapp_db';
$db_user = 'webapp_user';
$db_pass = 'WebApp123!';

// Server information
$server_name = '{{ server_name }}';
$server_color = '{{ server_color }}';
$db_role = '{{ db_role }}';

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Fetch all users
    $stmt = $pdo->query("SELECT * FROM users ORDER BY created_at DESC");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
} catch(PDOException $e) {
    die("Database connection failed: " . $e->getMessage());
}
?>
<?php include 'index_db_template.php'; ?>

<!-- Populate table with data -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    const users = <?php echo json_encode($users); ?>;
    const tbody = document.getElementById('userTableBody');
    
    if (users.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" style="text-align: center; color: #999;">No users found. Add some above!</td></tr>';
    } else {
        users.forEach(user => {
            const row = tbody.insertRow();
            row.innerHTML = `
                <td>${user.id}</td>
                <td><strong>${user.username}</strong></td>
                <td>${user.email}</td>
                <td>${user.server_name || 'N/A'}</td>
                <td>${new Date(user.created_at).toLocaleString()}</td>
            `;
        });
    }
});
</script>
