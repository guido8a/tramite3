<%--
  Created by IntelliJ IDEA.
  User: fabricio
  Date: 24/09/20
  Time: 12:21
--%>

<span>
    <label>
        Año
    </label>
    <g:select name="anioR" from="${parametros.Anio.list().sort{it.anio}}" class="form-control" optionKey="id" optionValue="anio"/>
 </span>