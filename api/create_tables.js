const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

(async () => {
  const pool = mysql.createPool({
    host: '43.138.4.157',
    user: 'root',
    password: 'Group21Password',
    database: 'campus_project',
    charset: 'utf8mb4'
  });

  try {
    const sqlPath = path.join(__dirname, '..', 'section_tables.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');
    
    // 分割SQL语句（按分号分割，但忽略注释）
    const statements = sql.split(';').filter(s => s.trim() && !s.trim().startsWith('--'));
    
    for (const stmt of statements) {
      if (stmt.trim()) {
        console.log('执行:', stmt.substring(0, 50).replace(/\n/g, ' ') + '...');
        await pool.execute(stmt.trim());
      }
    }
    
    console.log('✅ 所有表创建成功');
  } catch (err) {
    console.error('❌ 错误:', err.message);
    console.error('详细信息:', err);
  } finally {
    await pool.end();
  }
})();