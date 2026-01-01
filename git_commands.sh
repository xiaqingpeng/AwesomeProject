#!/bin/bash

# Git命令交互式脚本

echo "=========================================="
echo "       Git 命令交互式菜单"
echo "=========================================="
echo ""
echo "请选择要执行的命令："
echo "1) git pull --rebase"
echo "2) git push origin main"
echo "3) git push origin main -f"
echo "4) git reset --soft HEAD^"
echo "5) 退出"
echo ""
read -p "请输入选项 (1-5): " choice

case $choice in
    1)
        echo ""
        echo "执行: git pull --rebase"
        git pull --rebase
        ;;
    2)
        echo ""
        echo "执行: git push origin main"
        git push origin main
        ;;
    3)
        echo ""
        echo "执行: git push origin main -f"
        echo "警告: 强制推送可能会覆盖远程分支！"
        read -p "确认执行？(y/n): " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            git push origin main -f
        else
            echo "已取消操作"
        fi
        ;;
    4)
        echo ""
        echo "执行: git reset --soft HEAD^"
        echo "警告: 这将撤销最后一次提交但保留更改！"
        read -p "确认执行？(y/n): " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            git reset --soft HEAD^
        else
            echo "已取消操作"
        fi
        ;;
    5)
        echo "退出脚本"
        exit 0
        ;;
    *)
        echo "无效选项，请重新运行脚本"
        exit 1
        ;;
esac

echo ""
echo "命令执行完成"
