import groovy.transform.CompileStatic
import org.grails.encoder.CodecLookup
import org.grails.plugins.web.GrailsTagDateHelper
import org.grails.web.servlet.mvc.GrailsWebRequest
import org.springframework.context.MessageSource
import org.springframework.context.NoSuchMessageException
import org.springframework.util.StringUtils
import seguridad.Persona

import java.math.RoundingMode
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.text.NumberFormat

class UtilitariosTagLib {

    static namespace = "util"

    Closure clean = { attrs ->
        def replace = [
                "&aacute;": "á",
                "&eacute;": "é",
                "&iacute;": "í",
                "&oacute;": "ó",
                "&uacute;": "ú",
                "&ntilde;": "ñ",

                "&Aacute;": "Á",
                "&Eacute;": "É",
                "&Iacute;": "Í",
                "&Oacute;": "Ó",
                "&Uacute;": "Ú",
                "&Ntilde;": "Ñ",

                "&nbsp;"  : " ",

                "&lt;"    : "<",
                "&gt;"    : ">",

                "&amp;"   : "&",

                "&quot;"  : '"',

                "&lsquo;" : '‘',
                "&rsquo;" : '’',
                "&ldquo;" : '“',
                "&rdquo;" : '”',

                "&lsaquo;": '‹',
                "&rsaquo;": '›',
                "&laquo;" : '«',
                "&raquo;" : '»',

                "&permil;": '‰',

                "&hellip;": '...'
        ]
        def str = attrs.str

        replace.each { busca, nuevo ->
            str = str.replaceAll(busca, nuevo)
        }
        out << str
    }

    Closure capitalize = { attrs, body ->
        def str = body()
        if (str == "") {
            str = attrs.string
        }
        str = str.replaceAll(/[a-zA-Z_0-9áéíóúÁÉÍÓÚñÑüÜ]+/, {
            it[0].toUpperCase() + ((it.size() > 1) ? it[1..-1].toLowerCase() : '')
        })
        out << str
    }

    Closure nombrePersona = { attrs, body ->
        def persona = attrs.persona
        def str = ""
        if (persona instanceof Persona) {
            str = capitalize(string: persona.nombre + " " + persona.apellido)
        }
        out << str
    }

    Closure numero = { attrs ->
//        if (attrs.debug == "true" || attrs.debug == true) {
//            println "AQUI: " + attrs
//        }
        if (!attrs.decimales) {
            if (!attrs["format"]) {
                attrs["format"] = "##,##0"
            }
            if (!attrs.minFractionDigits) {
                attrs.minFractionDigits = 2
            }
            if (!attrs.maxFractionDigits) {
                attrs.maxFractionDigits = 2
            }
        } else {
            def dec = attrs.remove("decimales").toInteger()

            attrs["format"] = "##,##0"
            if (dec > 0) {
                attrs["format"] += "."
            }
            dec.times {
                attrs["format"] += "#"
            }

//            attrs["format"] = "##"
//            if (dec > 0) {
//                attrs["format"] += ","
//                dec.times {
//                    attrs["format"] += "#"
//                }
//                attrs["format"] += "0"
//            }
            attrs.maxFractionDigits = dec
            attrs.minFractionDigits = dec
        }
        if (!attrs.locale) {
            attrs.locale = "ec"
        }
        if (attrs.debug == "true" || attrs.debug == true) {
            println attrs
            println g.formatNumber(attrs)
            println g.formatNumber(number: attrs.number, maxFractionDigits: 3, minFractionDigits: 3, format: "##.###", locale: "ec")
            println g.formatNumber(number: attrs.number, maxFractionDigits: 3, minFractionDigits: 3, format: "##,###.###", locale: "ec")
        }
        if (attrs.cero == "false" || attrs.cero == false || attrs.cero == "hide") {
            if (attrs.number) {
                if (attrs.number.toDouble() == 0.toDouble()) {
                    out << ""
                    return
                }
            } else {
                out << ""
                return
            }
        }
        out << g.formatNumber(attrs)
    }

    Closure fechaConFormato = { attrs ->
        def fecha = attrs.fecha
        def formato = attrs.formato ?: "dd-MMM-yy"
        def meses = ["", "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"]
        def mesesLargo = ["", "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
        def strFecha = ""
        if (attrs.ciudad) {
            formato = "CCC, dd MMMM yyyy"
        }
//        println ">>" + fecha + "    " + formato
        if (fecha) {
            switch (formato) {
                case "MMM-yy":
                    strFecha = meses[fecha.format("MM").toInteger()] + "-" + fecha.format("yy")
                    break;
                case "dd-MM-yyyy":
                    strFecha = "" + fecha.format("dd-MM-yyyy")
                    break;
                case "dd-MMM-yyyy":
                    strFecha = "" + fecha.format("dd") + "-" + meses[fecha.format("MM").toInteger()] + "-" + fecha.format("yyyy")
                    break;
                case "dd-MMM-yy":
                    strFecha = "" + fecha.format("dd") + "-" + meses[fecha.format("MM").toInteger()] + "-" + fecha.format("yy")
                    break;
                case "dd MMMM yyyy":
                    strFecha = "" + fecha.format("dd") + " de " + mesesLargo[fecha.format("MM").toInteger()] + " de " + fecha.format("yyyy")
                    break;
                case "dd MMMM yyyy HH:mm:ss":
                    strFecha = "" + fecha.format("dd") + " de " + mesesLargo[fecha.format("MM").toInteger()] + " de " + fecha.format("yyyy") + " a las " + fecha.format("HH:mm:ss")
                    break;
                case "CCC, dd MMMM yyyy":
                    strFecha = attrs.ciudad + ", " + fecha.format("dd") + " de " + mesesLargo[fecha.format("MM").toInteger()] + " de " + fecha.format("yyyy")
                    break;
                default:
                    strFecha = "Formato " + formato + " no reconocido"
                    break;
            }
        }
//        println ">>>>>>" + strFecha
        out << strFecha
    }

    Closure fechaConFormatoMayusculas = { attrs ->
        def fecha = attrs.fecha
        def formato = attrs.formato ?: "dd-MMM-yy"
        def meses = ["", "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"]
        def mesesLargo = ["", "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"]
        def strFecha = ""
        if (attrs.ciudad) {
            formato = "CCC, dd MMMM yyyy"
        }
//        println ">>" + fecha + "    " + formato
        if (fecha) {
            switch (formato) {
                case "MMM-yy":
                    strFecha = meses[fecha.format("MM").toInteger()] + "-" + fecha.format("yy")
                    break;
                case "dd-MM-yyyy":
                    strFecha = "" + fecha.format("dd-MM-yyyy")
                    break;
                case "dd-MMM-yyyy":
                    strFecha = "" + fecha.format("dd") + "-" + meses[fecha.format("MM").toInteger()] + "-" + fecha.format("yyyy")
                    break;
                case "dd-MMM-yy":
                    strFecha = "" + fecha.format("dd") + "-" + meses[fecha.format("MM").toInteger()] + "-" + fecha.format("yy")
                    break;
                case "dd MMMM yyyy":
                    strFecha = "" + fecha.format("dd") + " de " + mesesLargo[fecha.format("MM").toInteger()] + " de " + fecha.format("yyyy")
                    break;
                case "dd MMMM yyyy HH:mm:ss":
                    strFecha = "" + fecha.format("dd") + " de " + mesesLargo[fecha.format("MM").toInteger()] + " de " + fecha.format("yyyy") + " a las " + fecha.format("HH:mm:ss")
                    break;
                case "CCC, dd MMMM yyyy":
                    strFecha = attrs.ciudad + ", " + fecha.format("dd") + " de " + mesesLargo[fecha.format("MM").toInteger()] + " de " + fecha.format("yyyy")
                    break;
                default:
                    strFecha = "Formato " + formato + " no reconocido"
                    break;
            }
        }
//        println ">>>>>>" + strFecha
        out << strFecha
    }

    def renderHTML = { attrs ->
        out << attrs.html
    }

    def separar = { attrs ->
        def salida = ""
        attrs.urls.split(' ').each {rf ->
            salida += "<a href='${rf}'  target=\"_blank\">${rf}</a><br/>"
        }
        out << salida
    }

    MessageSource messageSource
    CodecLookup codecLookup
    GrailsTagDateHelper grailsTagDateHelper

    @CompileStatic
    String messageHelper(String code, Object defaultMessage = null, List args = null, Locale locale = null) {
        if (locale == null) {
            locale = GrailsWebRequest.lookup().getLocale()
        }
        def message
        try {
            message = messageSource.getMessage(code, args == null ? null : args.toArray(), locale)
        }
        catch (NoSuchMessageException e) {
            if (defaultMessage != null) {
                if (defaultMessage instanceof Closure) {
                    message = defaultMessage()
                }
                else {
                    message = defaultMessage as String
                }
            }
        }
        return message
    }

    @CompileStatic
    static Locale resolveLocale(Object localeAttr) {
        Locale locale
        if (localeAttr instanceof Locale) {
            locale = (Locale)localeAttr
        } else if (localeAttr != null) {
            locale = StringUtils.parseLocaleString(localeAttr.toString())
        }
        if (locale == null) {
            locale = GrailsWebRequest.lookup().getLocale()
            if (locale == null) {
                locale = Locale.getDefault()
            }
        }
        return locale
    }



    Closure formatNumber = { attrs ->
        if (!attrs.containsKey('number')) {
            throwTagError("Tag [formatNumber] is missing required attribute [number]")
        }

        def number = attrs.number
        if (number == null) return

        def formatName = attrs.formatName
        def format = attrs.format
        def type = attrs.type
        def locale = resolveLocale(attrs.locale)

        if (type == null) {
            if (!format && formatName) {
                format = messageHelper(formatName,null,null,locale)
                if (!format) {
                    throwTagError("Attribute [formatName] of Tag [formatNumber] specifies a format key [$formatName] that does not exist within a message bundle!")
                }
            }
            else if (!format) {
                format = messageHelper("number.format", { messageHelper("default.number.format", "0", null, locale) } ,null ,locale)
            }
        }

//        DecimalFormatSymbols dcfs = locale ? new DecimalFormatSymbols(locale) : new DecimalFormatSymbols()
        DecimalFormatSymbols dcfs = DecimalFormatSymbols.getInstance();
//        decimalSymbols.setDecimalSeparator('.');
        Character a = '.'
        Character m = ','
//        String mask = '#,###.##'
        dcfs.setDecimalSeparator(a)
        dcfs.setGroupingSeparator(m)

        DecimalFormat decimalFormat

        if (!type) {
            decimalFormat = new DecimalFormat(format, dcfs)
        }
        else {
            if (type == 'currency') {
                decimalFormat = NumberFormat.getCurrencyInstance(locale)
            }
            else if (type == 'number') {
                decimalFormat = NumberFormat.getNumberInstance(locale)
            }
            else if (type == 'percent') {
                decimalFormat = NumberFormat.getPercentInstance(locale)
            }
            else {
                throwTagError("Attribute [type] of Tag [formatNumber] specifies an unknown type. Known types are currency, number and percent.")
            }
        }

        if (attrs.nan) {
            dcfs.naN = attrs.nan
            decimalFormat.decimalFormatSymbols = dcfs
        }

        // ensure formatting accuracy
        decimalFormat.setParseBigDecimal(true)

        if (attrs.currencyCode != null) {
            Currency currency = Currency.getInstance(attrs.currencyCode as String)
            decimalFormat.setCurrency(currency)
        }
        if (attrs.currencySymbol != null) {
            dcfs = decimalFormat.getDecimalFormatSymbols()
            dcfs.setCurrencySymbol(attrs.currencySymbol as String)
            decimalFormat.setDecimalFormatSymbols(dcfs)
        }
        if (attrs.groupingUsed != null) {
            if (attrs.groupingUsed instanceof Boolean) {
                decimalFormat.setGroupingUsed(attrs.groupingUsed)
            }
            else {
                // accept true, y, 1, yes
                decimalFormat.setGroupingUsed(attrs.groupingUsed.toString().toBoolean() ||
                        attrs.groupingUsed.toString() == 'yes')
            }
        }
        if (attrs.maxIntegerDigits != null) {
            decimalFormat.setMaximumIntegerDigits(attrs.maxIntegerDigits as Integer)
        }
        if (attrs.minIntegerDigits != null) {
            decimalFormat.setMinimumIntegerDigits(attrs.minIntegerDigits as Integer)
        }
        if (attrs.maxFractionDigits != null) {
            decimalFormat.setMaximumFractionDigits(attrs.maxFractionDigits as Integer)
        }
        if (attrs.minFractionDigits != null) {
            decimalFormat.setMinimumFractionDigits(attrs.minFractionDigits as Integer)
        }
        if (attrs.roundingMode != null) {
            def roundingMode = attrs.roundingMode
            if (!(roundingMode instanceof RoundingMode)) {
                roundingMode = RoundingMode.valueOf(roundingMode)
            }
            decimalFormat.setRoundingMode(roundingMode)
        }

        if (!(number instanceof Number)) {
            number = decimalFormat.parse(number as String)
        }

        def formatted
        try {
            formatted = decimalFormat.format(number)
        }
        catch(ArithmeticException e) {
            // if roundingMode is UNNECESSARY and ArithemeticException raises, just return original number formatted with default number formatting
            formatted = NumberFormat.getNumberInstance(locale).format(number)
        }
//        println "--> $number --> $formatted"
        out << formatted
//        return formatted
    }


}
