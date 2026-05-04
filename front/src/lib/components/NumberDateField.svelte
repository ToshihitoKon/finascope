<script lang="ts">
  interface DateValue {
    year: number;
    month: number;
    day: number;
  }

  interface Props {
    value?: DateValue;
    onValidationError?: (msg: string | null) => void;
  }

  let { value = $bindable(), onValidationError }: Props = $props();

  const today = new Date();
  let yearStr = $state(String(value?.year ?? today.getFullYear()));
  let monthStr = $state(String(value?.month ?? today.getMonth() + 1).padStart(2, '0'));
  let dayStr = $state(String(value?.day ?? today.getDate()).padStart(2, '0'));

  let container: HTMLDivElement;
  let isInvalid = $state(false);

  function validate() {
    const y = parseInt(yearStr, 10);
    const m = parseInt(monthStr, 10);
    const d = parseInt(dayStr, 10);
    const date = new Date(y, m - 1, d);
    if (date.getFullYear() === y && date.getMonth() + 1 === m && date.getDate() === d) {
      value = { year: y, month: m, day: d };
      isInvalid = false;
      onValidationError?.(null);
    } else {
      value = undefined;
      isInvalid = true;
      onValidationError?.('存在しない日付です');
    }
  }

  function handleFocusout(e: FocusEvent) {
    const next = e.relatedTarget as Node | null;
    if (next && container.contains(next)) return;
    // ゼロパディング正規化
    const m = parseInt(monthStr, 10);
    const d = parseInt(dayStr, 10);
    if (!isNaN(m)) monthStr = String(m).padStart(2, '0');
    if (!isNaN(d)) dayStr = String(d).padStart(2, '0');
    validate();
  }
</script>

<div class="layout-date-field" class:is-invalid={isInvalid} bind:this={container} onfocusout={handleFocusout}>
  <input
    class="input-year"
    type="text"
    inputmode="numeric"
    maxlength="4"
    bind:value={yearStr}
    aria-label="年"
  />
  <span class="sep">/</span>
  <input
    class="input-month"
    type="text"
    inputmode="numeric"
    maxlength="2"
    bind:value={monthStr}
    aria-label="月"
  />
  <span class="sep">/</span>
  <input
    class="input-day"
    type="text"
    inputmode="numeric"
    maxlength="2"
    bind:value={dayStr}
    aria-label="日"
  />
</div>

<style lang="scss">
  .layout-date-field {
    display: inline-flex;
    align-items: center;
    gap: 0;
    height: 28px;
    padding: 4px 0;
    border-bottom: 1px solid var(--color-border);
    box-sizing: border-box;
    font-size: inherit;
    font-family: inherit;
    transition: border-color 0.15s, background-color 0.15s;
  }

  .layout-date-field:focus-within {
    border-bottom-color: var(--color-primary);
    background-color: rgba(255, 255, 255, 0.6);
  }

  .layout-date-field.is-invalid {
    border-bottom-color: #dc3545;
    background-color: rgba(220, 53, 69, 0.08);
  }

  .layout-date-field.is-invalid:focus-within {
    border-bottom-color: #dc3545;
    background-color: rgba(220, 53, 69, 0.08);
  }

  .layout-date-field input {
    border: none;
    outline: none;
    background: transparent;
    font-size: inherit;
    font-family: inherit;
    font-weight: inherit;
    color: inherit;
    padding: 0;
    -moz-appearance: textfield;
    appearance: textfield;
    text-align: center;
  }

  .layout-date-field input::-webkit-inner-spin-button,
  .layout-date-field input::-webkit-outer-spin-button {
    -webkit-appearance: none;
    margin: 0;
  }

  /* コンポーネント内ローカルクラス（.claude/rules/front-style-naming.md の例外規定） */
  /* stylelint-disable selector-class-pattern */
  .input-year {
    width: 4ch;
  }

  .input-month {
    width: 2ch;
  }

  .input-day {
    width: 2ch;
  }

  .sep {
    padding: 0 2px;
    color: var(--color-text-muted);
    user-select: none;
  }
  /* stylelint-enable selector-class-pattern */

  @media (max-width: $bp-sp-max) {
    .layout-date-field {
      height: 36px; // 36px = SP でタップ領域確保（min 44px に近づける）
      padding: 6px 0; // 6px = 縦余白を増やしてタップしやすく
      font-size: 1rem; // SP では入力時に意図しないズームを避けるため 16px 相当
    }

    .layout-date-field input {
      font-size: 1rem; // 同上
    }
  }
</style>
