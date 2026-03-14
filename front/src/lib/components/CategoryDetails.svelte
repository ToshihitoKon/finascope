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

<style>
  .layout-details {
    max-width: 1024px;
    margin: 0 auto;
    padding: 0 16px;
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
    background-color: var(--color-primary-bg);
    padding: 8px 16px;
    white-space: nowrap;
  }

  .style-table td {
    padding: 8px 16px;
    height: 36px;
    white-space: nowrap;
    vertical-align: middle;
    text-align: left;
  }

  .style-table tbody > tr:nth-of-type(even):not(.style-new-row) {
    background-color: rgb(237 238 242);
  }

  .style-new-row {
    background-color: #f0f4ff;
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
    text-align: center;
    white-space: nowrap;
    width: 160px;
  }

  .style-button {
    background-color: var(--color-primary);
    color: white;
    border: none;
    border-radius: 8px;
    padding: 4px 8px;
    cursor: pointer;
  }

  .style-button:hover {
    opacity: 0.8;
  }

  .style-button-secondary {
    background-color: #6c757d;
    margin-left: 4px;
  }
</style>
