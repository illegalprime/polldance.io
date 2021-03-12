function form_change_event(form) {
    const trigger = document.getElementById(`${form.id}_trigger`);
    const event = document.createEvent("Event");
    event.initEvent("change", true, true);
    trigger.dispatchEvent(event);
}

export const DragTable = {
    mounted() {
        const inner = this.el.getElementsByTagName('tbody')[0];
        window.jquery_sortable(inner).sortable({
            handle: '.opt-drag',
            container: 'tbody',
            nodes: 'tr',
            nodes_type: 'tr',
            update: () => {
                form_change_event(this.el);
            },
        });
    },
};
