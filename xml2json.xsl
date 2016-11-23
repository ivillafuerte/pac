<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:lco="http:/www.sat.gob.mx/cfd/LCO">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:key name="group-by-rfc" match="lco:Contribuyente" use="@RFC"/>

<xsl:template match="lco:LCO">

<xsl:for-each select="lco:Contribuyente[count(. | key('group-by-rfc', @RFC)[1]) = 1]">
<xsl:sort select="@RFC"/>{"index":{"_index":"lco041116","_type":"contribuyente","_id":"<xsl:value-of select="./@RFC"/>"}
{"Certificados":[<xsl:for-each select="key('group-by-rfc', @RFC)"><xsl:for-each select="./*">{"ValidezObligaciones":"<xsl:value-of select="./@ValidezObligaciones"/>","EstatusCertificado":"<xsl:value-of select="./@EstatusCertificado"/>","NoCertificado":"<xsl:value-of select="./@noCertificado"/>","FechaFinal":"<xsl:value-of select="./@FechaFinal"/>","FechaInicio":"<xsl:value-of select="./@FechaInicio"/>"}<xsl:if test="position()!=last()">,</xsl:if></xsl:for-each><xsl:if test="position() != last()">,</xsl:if>
</xsl:for-each>]}
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>
