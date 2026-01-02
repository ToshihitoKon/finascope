<script lang="ts">
  import { Button, DateField } from '$lib/components';

  const newRecordValues = $state([{}]);
</script>

<div>
  <h2>明細一覧</h2>

  <div>
    <table>
      <thead>
        <tr>
          <th></th>
          <th>
            <span>日付</span>
          </th>
          <th>
            <span>金額</span>
          </th>
          <th>
            <span>カテゴリ</span>
          </th>
          <th>
            <span>支払方法</span>
          </th>
          <th>
            <span>何？</span>
          </th>
          <th>
            <span></span>
          </th>
        </tr>
      </thead>
      <tbody>
        <!-- サンプルデータ行 -->
        <tr>
          <td>
            <input type="checkbox" />
          </td>
          <td>
            <span>2024-12-27</span>
          </td>
          <td>
            <span>¥92,640</span>
          </td>
          <td>
            <span>趣味</span>
          </td>
          <td>
            <span>ANA Visa</span>
          </td>
          <td>
            <span>Fanatec GT DD Pro</span>
          </td>
          <td>
            <Button variant="primary">編集</Button>
          </td>
        </tr>

        <!-- 新規入力行1 -->
        <tr>
          <td>
            <input type="checkbox" disabled />
          </td>
          <td>
            <DateField />
          </td>
          <td>
            <input
              type="number"
              placeholder="金額"
            />
          </td>
          <td>
            <select></select>
          </td>
          <td>
            <select> </select>
          </td>
          <td>
            <input type="text" placeholder="円盤" />
          </td>
          <td>
            <Button variant="danger">削除</Button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
