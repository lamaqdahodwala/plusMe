<script>
    let name = $state("")

    function sayHello(){
        alert("Hello " + name)
    }
</script>

<button class="bg-red-100 p-3 rounded-lg border border-black m-3" onclick={sayHello}>This is a button</button>
<input bind:value={name}>