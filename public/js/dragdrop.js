function onDrop(event){
    var file = event.dataTransfer.files[0];
    console.log(file)
    var fd = new FormData(content);
    fd.append("file", file)

    $.ajax({
        url: '/upload',
        type: 'POST',
        data: fd,
        processData: false,
        contentType: false,
        success: function(data) {
            console.log('upload success');
            window.location.reload();
        }
    });
    event.preventDefault();
}
function onDragOver(event){
    event.preventDefault();
}
