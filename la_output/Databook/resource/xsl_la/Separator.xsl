<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xd="http://www.pnp-software.com/XSLTdoc">

  <!--
  Copyright (C) 1984-2024 Silvaco, Inc.                    
  All rights reserved.                            
                                                                             
  The Silvaco name and the Silvaco logo are trademarks of Silvaco, Inc.      
  and/or its affiliates ("Silvaco"). All trademarks, logos, software marks,  
  and trade names (collectively, the "Marks") in this program are            
  proprietary to Silvaco or other respective owners that have granted        
  Silvaco the right and license to use such Marks. You are not permitted to  
  use the Marks without the prior written consent of Silvaco or such third   
  party that may own the Marks.                                              
                                                                             
  This file has been provided pursuant to a license agreement containing     
  restrictions on its use. This file contains valuable trade secrets and     
  proprietary information of Silvaco and is protected by U.S. and            
  international laws.                                                        
                                                                             
  The copyright notice(s) in this file do not indicate actual or intended    
  publication of this file.                                                  
  -->

  <xsl:include href="NavigationBar.xsl"/>

  <xd:doc>Creates a separator page for PDF databook, dividing each library/corner in a different section</xd:doc>
  <xsl:template match="Corner">
   
    <html>
      <head>
        <title>
          <xsl:value-of select="'Silvaco Default Separator Page'"/>
        </title>
        <xsl:call-template name="Includes"/>
      </head>
      <body>

        <xsl:call-template name="SilvacoHeader">
          <xsl:with-param name="dir">.</xsl:with-param>
          <xsl:with-param name="Title"><xsl:value-of select="''"/></xsl:with-param>
        </xsl:call-template>

        <hr/>
        
        <table class="navigation">
          <tr><td>Copyright <xsl:text>©</xsl:text> 1984-2024 Silvaco, Inc. All rights reserved.</td></tr>
          <tr><td>Build Date: <xsl:value-of select="$XmlCornerList/CornerList/Date"/></td></tr>
        </table>
        
        <xsl:variable name="alias"><xsl:value-of select="@Alias"/></xsl:variable>      
        <xsl:variable name="corner"><xsl:value-of select="@CornerName"/></xsl:variable>
 
        <br/><br/><br/><br/><br/><br/>
        <br/><br/><br/><br/><br/><br/>

        <xsl:if test="$alias!=''">
          <xsl:if test="$alias!=$AbsDeviation and $alias!=$RelDeviation">
            <p align="center" class="Title">Library</p>
          </xsl:if>
          <br/><br/><br/>
          <p align="center" class="SubTitle">
            <xsl:call-template name="SplitString">
              <xsl:with-param name="string" select="$alias"/>
              <xsl:with-param name="max_size" select="'55'"/>
              <xsl:with-param name="lin_pos" select="'0'"/>
            </xsl:call-template>
<!--        <xsl:value-of select="$alias"/> -->
          </p>
        </xsl:if>

        <br/><br/><br/><br/><br/><br/>

        <xsl:if test="$corner!=''">
          <p align="center" class="Title">Corner</p>
          <br/><br/><br/>
          <p align="center" class="SubTitle">
            <xsl:call-template name="SplitString">
              <xsl:with-param name="string" select="$corner"/>
              <xsl:with-param name="max_size" select="'50'"/>
              <xsl:with-param name="lin_pos" select="'0'"/>
            </xsl:call-template>
<!--        <xsl:value-of select="$corner"/> -->
          </p>
        </xsl:if>     

      </body>
    </html>
  </xsl:template>

  <xsl:template match="PdfCoverPage">
   
    <html>
      <head>
        <title>
          <xsl:value-of select="'Silvaco Default Cover Page'"/>
        </title>
        <xsl:call-template name="Includes"/>
      </head>
      <body>

        <xsl:call-template name="SilvacoHeader">
          <xsl:with-param name="dir">.</xsl:with-param>
          <xsl:with-param name="Title"><xsl:value-of select="''"/></xsl:with-param>
        </xsl:call-template>

        <hr/>
 
        <br/><br/><br/><br/><br/><br/>
        <br/><br/><br/><br/><br/><br/>
        <br/><br/><br/><br/><br/><br/>

        <p align="center" class="PdfTitle">Library</p>
        <p align="center" class="PdfTitle">Datasheet</p>

        <br/><br/><br/><br/><br/><br/>
        <br/><br/><br/><br/><br/><br/>
        <br/><br/><br/><br/><br/><br/>
        <br/><br/><br/><br/><br/><br/>
        <br/><br/><br/><br/><br/><br/>

        <hr/>

      </body>
    </html>
  </xsl:template>
  
</xsl:stylesheet>
