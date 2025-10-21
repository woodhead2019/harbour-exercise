/*
codling=utf-8
Harbour SQLite 示例程序
演示如何使用 Harbour 的 SQLite 库进行数据库操作
 */

REQUEST HB_LANG_zh_sim

REQUEST HB_CODEPAGE_UTF8
REQUEST HB_CODEPAGE_UTF8EX

#require "hbsqlit3"
#include "fileio.ch"

PROCEDURE Main()
   LOCAL pDb, cDbFile := "test.db"
   LOCAL cSQL, aRow, i
   LOCAL nRows, nCols
   LOCAL lCreateIfNotExist := .T.


   CLS
   hb_cdpSelect( 'UTF8' )   /* 要和prg源程序的文字编码一致 */
   hb_langSelect( 'zh_sim' )

   ? "========================================="
   ? "  Harbour SQLite 数据库示例程序"
   ? "========================================="
   ? ""

   ? sqlite3_libversion()
   sqlite3_sleep( 3000 )

   IF sqlite3_libversion_number() < 3005001
      RETURN
   ENDIF

 
   // 删除已存在的数据库文件（用于测试）
   IF File( cDbFile )
      FErase( cDbFile )
      ? "删除旧数据库文件: " + cDbFile
   ENDIF

   // 1. 打开/创建数据库
   ? "1. 创建数据库连接..."
   pDb := sqlite3_open( cDbFile , lCreateIfNotExist )
   IF Empty( pDb )
      ? "错误：无法创建数据库!"
      RETURN
   ENDIF
   ? "   成功：数据库已创建"
   ? ""

   // 2. 创建表
   ? "2. 创建数据表..."
   cSQL := "CREATE TABLE students (" + ;
           "id INTEGER PRIMARY KEY AUTOINCREMENT, " + ;
           "name TEXT NOT NULL, " + ;
           "age INTEGER, " + ;
           "grade REAL, " + ;
           "class TEXT);"

   IF sqlite3_exec( pDb, cSQL ) == SQLITE_OK
      ? "   成功：students 表已创建"
   ELSE
      ? "   错误：" + sqlite3_errmsg( pDb )
   ENDIF
   ? ""

   // 3. 插入数据
   ? "3. 插入学生数据..."

   cSQL := "INSERT INTO students (name, age, grade, class) VALUES " + ;
           "('张三', 18, 95.5, '计算机一班');"
   sqlite3_exec( pDb, cSQL )

   cSQL := "INSERT INTO students (name, age, grade, class) VALUES " + ;
           "('李四', 19, 88.0, '计算机一班');"
   sqlite3_exec( pDb, cSQL )

   cSQL := "INSERT INTO students (name, age, grade, class) VALUES " + ;
           "('王五', 20, 92.5, '计算机二班');"
   sqlite3_exec( pDb, cSQL )

   cSQL := "INSERT INTO students (name, age, grade, class) VALUES " + ;
           "('赵六', 18, 87.0, '计算机二班');"
   sqlite3_exec( pDb, cSQL )

   cSQL := "INSERT INTO students (name, age, grade, class) VALUES " + ;
           "('孙七', 19, 91.0, '计算机一班');"
   sqlite3_exec( pDb, cSQL )

   ? "   成功：已插入 5 条学生记录"
   ? ""

   // 4. 查询所有数据
   ? "4. 查询所有学生信息..."
   ? ""
   cSQL := "SELECT * FROM students;"

   aRow := sqlite3_get_table( pDb, cSQL )

   IF !Empty( aRow )
      // 打印表头
      ? "   " + PadR( "ID", 5 ) + ;
        PadR( "姓名", 10 ) + ;
        PadR( "年龄", 6 ) + ;
        PadR( "成绩", 8 ) + ;
        "班级"
      ? "   " + Replicate( "-", 60 )

      // 打印数据（跳过表头行，从第2行开始）
      FOR i := 2 TO Len( aRow )
         ? "   " + ;
           PadR( aRow[i][1], 5 ) + ;
           PadR( aRow[i][2], 10 ) + ;
           PadR( aRow[i][3], 6 ) + ;
           PadR( aRow[i][4], 8 ) + ;
           aRow[i][5]
      NEXT
   ENDIF
   ? ""

   // 5. 条件查询
   ? "5. 查询成绩大于 90 分的学生..."
   ? ""
   cSQL := "SELECT name, age, grade, class FROM students WHERE grade > 90 ORDER BY grade DESC;"

   aRow := sqlite3_get_table( pDb, cSQL )

   IF !Empty( aRow ) .AND. Len( aRow ) > 1
      ? "   " + PadR( "姓名", 10 ) + ;
        PadR( "年龄", 6 ) + ;
        PadR( "成绩", 8 ) + ;
        "班级"
      ? "   " + Replicate( "-", 60 )

      FOR i := 2 TO Len( aRow )
         ? "   " + ;
           PadR( aRow[i][1], 10 ) + ;
           PadR( aRow[i][2], 6 ) + ;
           PadR( aRow[i][3], 8 ) + ;
           aRow[i][4]
      NEXT
   ENDIF
   ? ""

   // 6. 更新数据
   ? "6. 更新数据：给张三的成绩加 2 分..."
   cSQL := "UPDATE students SET grade = grade + 2 WHERE name = '张三';"

   IF sqlite3_exec( pDb, cSQL ) == SQLITE_OK
      ? "   成功：已更新 " + AllTrim( Str( sqlite3_changes( pDb ) ) ) + " 条记录"

      // 验证更新
      cSQL := "SELECT name, grade FROM students WHERE name = '张三';"
      aRow := sqlite3_get_table( pDb, cSQL )
      IF !Empty( aRow ) .AND. Len( aRow ) > 1
         ? "   张三的新成绩: " + aRow[2][2]
      ENDIF
   ENDIF
   ? ""

   // 7. 聚合查询
   ? "7. 统计信息..."
   cSQL := "SELECT class, COUNT(*) as count, AVG(grade) as avg_grade, " + ;
           "MAX(grade) as max_grade, MIN(grade) as min_grade " + ;
           "FROM students GROUP BY class;"

   aRow := sqlite3_get_table( pDb, cSQL )

   IF !Empty( aRow ) .AND. Len( aRow ) > 1
      ? "   " + PadR( "班级", 15 ) + ;
        PadR( "人数", 8 ) + ;
        PadR( "平均分", 10 ) + ;
        PadR( "最高分", 10 ) + ;
        "最低分"
      ? "   " + Replicate( "-", 60 )

      FOR i := 2 TO Len( aRow )
         ? "   " + ;
           PadR( aRow[i][1], 15 ) + ;
           PadR( aRow[i][2], 8 ) + ;
           PadR( Transform( Val(aRow[i][3]), "999.99" ), 10 ) + ;
           PadR( aRow[i][4], 10 ) + ;
           aRow[i][5]
      NEXT
   ENDIF
   ? ""

   // 8. 删除数据
   ? "8. 删除年龄小于 19 的学生记录..."
   cSQL := "DELETE FROM students WHERE age < 19;"

   IF sqlite3_exec( pDb, cSQL ) == SQLITE_OK
      ? "   成功：已删除 " + AllTrim( Str( sqlite3_changes( pDb ) ) ) + " 条记录"
   ENDIF
   ? ""

   // 9. 查看剩余数据
   ? "9. 查看剩余的学生信息..."
   ? ""
   cSQL := "SELECT * FROM students;"

   aRow := sqlite3_get_table( pDb, cSQL )

   IF !Empty( aRow )
      ? "   " + PadR( "ID", 5 ) + ;
        PadR( "姓名", 10 ) + ;
        PadR( "年龄", 6 ) + ;
        PadR( "成绩", 8 ) + ;
        "班级"
      ? "   " + Replicate( "-", 60 )

      FOR i := 2 TO Len( aRow )
         ? "   " + ;
           PadR( aRow[i][1], 5 ) + ;
           PadR( aRow[i][2], 10 ) + ;
           PadR( aRow[i][3], 6 ) + ;
           PadR( aRow[i][4], 8 ) + ;
           aRow[i][5]
      NEXT
      ? ""
      ? "   总共 " + AllTrim( Str( Len( aRow ) - 1 ) ) + " 条记录"
   ENDIF
   ? ""

   // 10. 关闭数据库
   ? "10. 关闭数据库连接..."
   // sqlite3_close( pDb )
   ? "    成功：数据库已关闭"
   ? ""

   ? "========================================="
   ? "  演示完成!"
   ? "========================================="
   ? ""
   ? "数据库文件 '" + cDbFile + "' 已保存在当前目录"
   ? ""

RETURN
