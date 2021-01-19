
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
    <head>
        <meta name="layout" content="main">
        <title>Cerrar año</title>
    </head>

    <body>
        <elm:flashMessage tipo="error" contenido="${flash.message}"/>

        <util:renderHTML html="${js}"/>
    </body>
</html>