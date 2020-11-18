<!DOCTYPE html>
<html lang="es">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

        <title>Solicitud de reforma al POA</title>
        <rep:estilos orientacion="l" pagTitle="${layoutTitle(default: 'Vesta')}"/>

        <style type="text/css">
        table {
            font-size : 9pt;
        }

        ol {
            counter-reset : item;
            padding       : 0;
        }

        ol li {
            display       : block;
            margin-bottom : 5px;
        }

        ol li:before {
            content           : counter(item) ". ";
            counter-increment : item;
            font-weight       : bold;
        }

        .table {
            border-collapse : collapse;
            border          : solid 1px #000000;
        }

        .justificacion {
            border     : solid 1px #000000;
            margin-top : 5px;
            padding    : 10px;
        }

        .firma {
            margin-top  : 2cm;
            margin-left : 10cm;
        }

        td, th {
            border  : solid 1px #000000;
            padding : 3px;
        }

        .text-right {
            text-align : right;
        }

        .table {
            width      : 100%;
            margin-top : 15px;
        }

        .table thead th {
            background : #9dbfdb;
            text-align : center;
        }

        .formato {
            font-weight : bold;
            background  : #008080;
            color       : #ffffff;
        }

        tr.success td {
            background : #b3cea7;
        }

        tr.info td {
            background : #c0ccdf;
        }
        </style>

    </head>

    <body>
        <g:layoutBody/>
    </body>
</html>
