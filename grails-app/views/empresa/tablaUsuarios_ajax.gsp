<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 07/10/21
  Time: 11:52
--%>

<div style="width: 100%;height: 600px;overflow: auto; margin-top: -20px;margin-bottom: 20px;">
    <table class="table table-condensed table-bordered">
        <tbody>
        <g:each in="${usuarios}" var="usuario">
            <tr style="width: 100%" data-id="${usuario.usro__id}" class="${usuario.usroetdo == 1 ? 'activo' : 'inactivo'}">
                <td style="width: 10%">${usuario.usrologn}</td>
                <td style="width: 25%">${usuario.usronmbr}</td>
                <td style="width: 25%">${usuario.usroapll}</td>
                <td style="width: 25%">${usuario.dptodscr}</td>
                <td style="width: 15%">${usuario.usroprfl}</td>
            </tr>
        </g:each>
        </tbody>
    </table>
</div>

<script type="text/javascript">


    $(function () {
        $("tr").contextMenu({
            items  : createContextMenu,
            onShow : function ($element) {
                $element.addClass("trHighlight");
            },
            onHide : function ($element) {
                $(".trHighlight").removeClass("trHighlight");
            }
        });
    });

</script>