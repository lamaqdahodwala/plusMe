<script module>
	import { defineMeta } from '@storybook/addon-svelte-csf';
	import SignUpSuccess from '#lib/components/SignUpSuccess.svelte';

	const { Story } = defineMeta({
		title: 'Components/SignUpSuccess',
		component: SignUpSuccess,
		tags: ['autodocs']
	});
</script>

<Story name="Default" />
