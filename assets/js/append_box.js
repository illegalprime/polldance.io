function add_option(socket, input) {
    socket.pushEvent("add_option", {
        option: input.value,
        idx: input.dataset.idx,
    });
    input.value = "";
}

export const AppendToItem = {
    mounted() {
        const input = this.el.getElementsByTagName('input')[0];
        const button = this.el.getElementsByTagName('button')[0];

        input.addEventListener("keydown", event => {
            if (event.keyCode !== 13) {
                return true;
            }
            add_option(this, input);
            event.preventDefault();
            return false;
        });

        button.addEventListener("click", event => {
            add_option(this, input);
            event.preventDefault();
            return false;
        });
    },
};
