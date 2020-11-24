<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 24/11/20
  Time: 10:37
--%>
<g:hiddenField name="idNumero" value="${numero?.id}"/>
<g:textField name="valor" id="idValor" class="form-control number" value="${numero?.valor ?: ''}" maxlength="4"/>

<script type="text/javascript">
    $("#idValor").keydown(function (ev) {
        return validarNum(ev)
    });

    function validarNum(ev) {
        /*
         48-57      -> numeros
         96-105     -> teclado numerico
         188        -> , (coma)
         190        -> . (punto) teclado
         110        -> . (punto) teclado numerico
         8          -> backspace
         46         -> delete
         9          -> tab
         37         -> flecha izq
         39         -> flecha der
         */
        return ((ev.keyCode >= 48 && ev.keyCode <= 57) ||
            (ev.keyCode >= 96 && ev.keyCode <= 105) ||
            ev.keyCode == 8 || ev.keyCode == 46 || ev.keyCode == 9 ||
            ev.keyCode == 37 || ev.keyCode == 39);
    }


</script>