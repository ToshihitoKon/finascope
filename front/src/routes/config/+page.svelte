<script>
  import {
    Card,
    CardContent,
    CardDescription,
    CardFooter,
    CardHeader,
    CardTitle
  } from '$lib/components/ui/card';
  import { Button } from '$lib/components/ui/button';
</script>

<div class="container max-w-screen-lg py-8">
  <h1 class="mb-6 text-2xl font-bold">設定</h1>

  <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
    <!-- カテゴリ設定カード -->
    <Card class="transition-shadow hover:shadow-lg">
      <CardHeader>
        <CardTitle>カテゴリ</CardTitle>
        <CardDescription>取引のカテゴリを管理します</CardDescription>
      </CardHeader>
      <CardContent>
        <p class="text-sm text-gray-500">
          収入・支出を分類するためのカテゴリ一覧の確認や編集ができます
        </p>
      </CardContent>
      <CardFooter>
        <Button variant="outline" class="w-full" href="config/categories">
          カテゴリ一覧を表示
        </Button>
      </CardFooter>
    </Card>

    <!-- 支払い方法設定カード -->
    <Card class="transition-shadow hover:shadow-lg">
      <CardHeader>
        <CardTitle>支払い方法</CardTitle>
        <CardDescription>利用できる支払い方法を管理します</CardDescription>
      </CardHeader>
      <CardContent>
        <p class="text-sm text-gray-500">
          現金、クレジットカードなどの支払い方法を確認・編集できます
        </p>
      </CardContent>
      <CardFooter>
        <Button variant="outline" class="w-full" href="config/payment_methods">
          支払い方法一覧を表示
        </Button>
      </CardFooter>
    </Card>
  </div>
</div>
