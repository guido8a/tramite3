<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 22/10/20
  Time: 16:58
--%>



<table class="table table-condensed table-hover table-striped table-bordered">
    <thead>
    <tr>
        <th style="width: 10%">Número</th>
        <th style="width: 45%">Fecha Desde</th>
        <th style="width: 45%">Fecha Hasta</th>
    </tr>
    </thead>
</table>

<div class=""  style="width: 99.7%;height: 350px; overflow-y: auto;float: right; margin-top: -20px">
    <table id="tablaB" class="table-bordered table-condensed table-hover" width="100%">
        <tbody>
        <g:each status="i" in="${periodos}" var="periodo" >
            <tr style="text-align: center" data-id="${periodo?.id}">
                <td style="width: 10%">${total-i}</td>
                <td style="width: 44%">${periodo?.fechaDesde?.format("dd-MM-yyyy")}</td>
                <td style="width: 44%">${periodo?.fechaHasta?.format("dd-MM-yyyy")}</td>
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