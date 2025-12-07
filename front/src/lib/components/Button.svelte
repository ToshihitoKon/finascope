<script lang="ts">
  import { Button as BitsButton } from 'bits-ui';

  interface Props {
    variant?: 'primary' | 'secondary' | 'danger' | 'link';
    size?: 'sm' | 'md' | 'lg';
    class?: string;
    disabled?: boolean;
    href?: string;
    // FIXIT: Don't use any
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    [key: string]: any;
  }

  let {
    variant = 'primary',
    size = 'md',
    class: className = '',
    children, 
    // FIXIT: https://svelte.dev/docs/svelte/compiler-warnings#custom_element_props_identifier
    // eslint-disable-next-line svelte/valid-compile
    ...restProps
  }: Props = $props();

  const variantClasses = {
    primary: 'bg-[#E86B79] hover:bg-[#d55a6a] text-white rounded transition-colors',
    secondary:
      'bg-white hover:bg-gray-50 text-gray-600 border border-gray-300 rounded transition-colors',
    danger: 'text-red-600 hover:text-red-700 transition-colors',
    link: 'text-[#E86B79] hover:text-[#d55a6a] transition-colors'
  };

  const sizeClasses = {
    sm: 'px-3 py-1 text-xs',
    md: 'px-4 py-2 text-sm',
    lg: 'px-6 py-3 text-base'
  };

  const computedClass = `${variantClasses[variant]} ${sizeClasses[size]} ${className}`.trim();
</script>

<BitsButton.Root class={computedClass} {...restProps}>
  {@render children?.()}
</BitsButton.Root>
