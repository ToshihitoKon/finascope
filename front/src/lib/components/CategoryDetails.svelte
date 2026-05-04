<script lang="ts">
  import { onMount } from 'svelte';
  import type { Category } from '$lib/api/v1/types';
  import * as api from '$lib/api/v1';
  import { toast } from 'svelte-sonner';

  let categories = $state<Category[]>([]);
  let editingId = $state<string | null>(null);
  let editingLabel = $state<string>('');
  let newLabel = $state<string>('');

  async function loadCategories() {
    const res = await api.fetchCategories();
    categories = res.categories;
  }

  onMount(loadCategories);

  function startEdit(cat: Category) {
    editingId = cat.id;
    editingLabel = cat.label;
  }

  function cancelEdit() {
    editingId = null;
    editingLabel = '';
  }

  async function handleUpdate(id: string) {
    if (!editingLabel.trim()) {
      toast.error('カテゴリ名を入力してください');
      return;
    }
    try {
      await api.updateCategory({ id, label: editingLabel.trim() });
      toast.success('カテゴリを更新しました');
      editingId = null;
      editingLabel = '';
      await loadCategories();
    } catch {
      toast.error('カテゴリの更新に失敗しました');
    }
  }

  async function handleCreate() {
    if (!newLabel.trim()) {
      toast.error('カテゴリ名を入力してください');
      return;
    }
    try {
      await api.createCategory({ label: newLabel.trim() });
      toast.success('カテゴリを追加しました');
      newLabel = '';
      await loadCategories();
    } catch {
      toast.error('カテゴリの追加に失敗しました');
    }
  }
</script>

<div class="layout-details">
  <h2>カテゴリ</h2>
  <div class="layout-table-scroll">
    <table class="style-table">
      <thead>
        <tr>
          <th><span>カテゴリ名</span></th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        {#each categories as cat (cat.id)}
          <tr>
            {#if editingId === cat.id}
              <td>
                <input type="text" bind:value={editingLabel} />
              </td>
              <td class="layout-actions">
                <button class="style-button" onclick={() => handleUpdate(cat.id)}>保存</button>
                <button class="style-button style-button-secondary" onclick={cancelEdit}>キャンセル</button>
              </td>
            {:else}
              <td><span>{cat.label}</span></td>
              <td class="layout-actions">
                <button class="style-button" onclick={() => startEdit(cat)}>編集</button>
              </td>
            {/if}
          </tr>
        {/each}

        <!-- 新規追加行 -->
        <tr class="style-new-row">
          <td>
            <input type="text" placeholder="カテゴリ名" bind:value={newLabel} />
          </td>
          <td class="layout-actions">
            <button class="style-button" onclick={handleCreate}>追加</button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>

<style lang="scss">
  .layout-details {
    width: 100%;
  }

  .layout-details h2 {
    margin: 0 0 16px;
    font-size: 1rem;
    font-weight: 700;
    color: #1f2937;
    letter-spacing: 0.02em;
  }

  .layout-table-scroll {
    overflow-x: auto;
    width: 100%;
    scrollbar-width: none;
  }

  .layout-table-scroll::-webkit-scrollbar {
    display: none;
  }

  .style-table {
    border-collapse: collapse;
    width: 100%;
    max-width: 960px;
    min-width: 400px;
  }

  .style-table th {
    background-color: var(--color-table-header-bg);
    padding: 8px 16px;
    white-space: nowrap;
    border-bottom: 1px solid var(--color-border);
    font-size: 0.75rem;
    font-weight: 600;
    color: var(--color-text-muted);
    text-transform: uppercase;
    letter-spacing: 0.04em;
  }

  .style-table td {
    padding: 8px 16px;
    height: 36px;
    white-space: nowrap;
    vertical-align: middle;
    text-align: left;
    border-bottom: 1px solid var(--color-border);
  }

  .style-new-row {
    background-color: var(--color-table-header-bg);
  }

  .style-table input[type='text'] {
    width: 100%;
    padding: 4px 8px;
    border: none;
    border-bottom: 1px solid transparent;
    box-sizing: border-box;
    font-size: 0.875rem;
    font-family: inherit;
    height: 28px;
    background-color: transparent;
    color: inherit;
    outline: none;
    vertical-align: middle;
    transition: border-color 0.15s, background-color 0.15s;
  }

  .style-table input[type='text']:focus {
    border-bottom-color: var(--color-primary);
    background-color: rgba(255, 255, 255, 0.6);
  }

  .style-table input::placeholder {
    color: #bbb;
  }

  .layout-actions {
    text-align: right;
    white-space: nowrap;
    width: 160px;
  }

  .style-button {
    background-color: transparent;
    color: var(--color-primary);
    border: 1px solid var(--color-primary);
    border-radius: 4px;
    padding: 3px 10px;
    cursor: pointer;
    font-size: 0.8rem;
  }

  .style-button:hover {
    background-color: var(--color-primary);
    color: white;
  }

  .style-button-secondary {
    color: #6c757d;
    border-color: #6c757d;
    margin-left: 4px;
  }

  .style-button-secondary:hover {
    background-color: #6c757d;
    color: white;
  }

  @media (max-width: $bp-sp-max) {
    .style-table {
      // SP 360px 幅に収まるよう min-width を緩和
      min-width: 320px;
    }

    .style-table th,
    .style-table td {
      padding: 8px 10px;
    }

    .style-table input[type='text'] {
      // 16px 未満だと iOS Safari がフォーカス時にズームしてしまうため 1rem
      font-size: 1rem;
      height: 36px;
    }

    .style-button {
      padding: 8px 12px;
      font-size: 0.875rem;
    }

    .layout-actions {
      width: auto;
    }
  }
</style>
