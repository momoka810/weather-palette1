#!/bin/bash
# Git履歴をクリーンにするスクリプト
# 必要なファイルだけを残した新しい履歴を作成します

echo "=========================================="
echo "Git履歴をクリーンにする"
echo "=========================================="
echo ""
echo "⚠️  警告: この操作はGit履歴を書き換えます"
echo "既にGitHubにプッシュしている場合、force pushが必要になります"
echo ""

read -p "続行しますか？ (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "キャンセルしました"
    exit 1
fi

# 現在のブランチを確認
CURRENT_BRANCH=$(git branch --show-current)
echo "現在のブランチ: $CURRENT_BRANCH"
echo ""

# バックアップブランチを作成（念のため）
BACKUP_BRANCH="backup-$(date +%Y%m%d-%H%M%S)"
echo "バックアップブランチを作成: $BACKUP_BRANCH"
git branch "$BACKUP_BRANCH"
echo "✅ バックアップ完了"
echo ""

# 必要なファイルのリスト
REQUIRED_FILES=(
    ".gitignore"
    "README.md"
    "api_key.txt.example"
    "index.html"
    "script.js"
    "styles.css"
)

# 一時的なブランチを作成
TEMP_BRANCH="temp-clean-$(date +%Y%m%d-%H%M%S)"
git checkout --orphan "$TEMP_BRANCH"
echo "✅ 新しいオーファンブランチを作成: $TEMP_BRANCH"
echo ""

# 必要なファイルだけを追加
echo "必要なファイルを追加しています..."
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        git add "$file"
        echo "  ✅ $file"
    else
        echo "  ⚠️  $file が見つかりません"
    fi
done
echo ""

# 初回コミット
echo "クリーンな履歴で初回コミットを作成..."
git commit -m "Initial commit: Weather Palette - 服の色管理・コーデ提案Webツール"
echo "✅ コミット完了"
echo ""

# 元のブランチに戻る
git checkout "$CURRENT_BRANCH"
echo "✅ 元のブランチに戻りました: $CURRENT_BRANCH"
echo ""

# 元のブランチを削除して、新しいブランチに置き換え
read -p "元のmainブランチを新しいクリーンな履歴に置き換えますか？ (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git branch -D "$CURRENT_BRANCH"
    git branch -m "$TEMP_BRANCH" "$CURRENT_BRANCH"
    echo "✅ ブランチを置き換えました"
    echo ""
    echo "次のステップ:"
    echo "1. 変更を確認: git log --oneline"
    echo "2. GitHubにforce push: git push -f origin $CURRENT_BRANCH"
    echo ""
    echo "⚠️  注意: force pushは既存の履歴を上書きします"
else
    echo "新しいブランチ '$TEMP_BRANCH' が作成されました"
    echo "手動でマージまたは置き換えてください"
fi

echo ""
echo "バックアップブランチ: $BACKUP_BRANCH"
echo "（必要に応じて git branch -D $BACKUP_BRANCH で削除できます）"

