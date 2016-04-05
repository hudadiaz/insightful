function screenGrabber(title) {
    var time = new Date().getTime();
    html2canvas($(".container"), {
        allowTaint: true,
        useCORS: true,
        letterRendering: true,
        onrendered: function (canvas) {
            var a = document.createElement('a');
            a.href = canvas.toDataURL();
            a.download = time+"_"+title+".jpg";
            a.click();
            window.close();
        }
    });
}