<script lang="ts">
  import { base } from '$app/paths';
  import { Button } from '$lib/components/ui/button/index.js';
  import * as Card from '$lib/components/ui/card/index.js';
</script>

<div class="container max-w-screen-md">
  <h1 class="mb-6 text-2xl font-bold">Views</h1>

  <div class="grid gap-4">
    <Card.Root>
      <Card.Header>
        <Card.Title>カテゴリ別集計</Card.Title>
        <Card.Description>
          期間を指定してカテゴリごとの支出を集計し、詳細なレコード一覧を確認できます。
        </Card.Description>
      </Card.Header>
      <Card.Content>
        <a href="{base}/view/categories">
          <Button>カテゴリ別集計を見る</Button>
        </a>
      </Card.Content>
    </Card.Root>
  </div>
</div>
