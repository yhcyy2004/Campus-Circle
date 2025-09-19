const mysql = require('mysql2/promise');
const fs = require('fs');
require('dotenv').config();

// MySQL数据库连接配置
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'Group21Password',
  database: process.env.DB_DATABASE || 'campus_project',
  charset: 'utf8mb4',
  multipleStatements: true
};

async function setupSectionTables() {
  let connection;
  try {
    console.log('🔗 连接数据库...');
    connection = await mysql.createConnection(dbConfig);
    console.log('✅ 数据库连接成功');

    // 读取SQL文件
    const sqlContent = fs.readFileSync('../section_tables.sql', 'utf8');
    
    console.log('📝 执行SQL文件...');
    
    // 分割SQL语句并逐个执行
    const statements = sqlContent
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));
    
    for (let statement of statements) {
      if (statement.trim()) {
        try {
          await connection.execute(statement);
          console.log('✅ 执行成功:', statement.substring(0, 50) + '...');
        } catch (error) {
          if (error.code === 'ER_TABLE_EXISTS_ERROR') {
            console.log('⚠️  表已存在:', statement.substring(0, 50) + '...');
          } else {
            console.error('❌ 执行失败:', error.message);
            console.error('SQL:', statement.substring(0, 100) + '...');
          }
        }
      }
    }
    
    // 检查表是否创建成功
    const [tables] = await connection.execute("SHOW TABLES LIKE '%section%'");
    console.log('📋 分区相关表:', tables);
    
    console.log('🎉 数据库设置完成!');
    
  } catch (error) {
    console.error('❌ 设置失败:', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

setupSectionTables();