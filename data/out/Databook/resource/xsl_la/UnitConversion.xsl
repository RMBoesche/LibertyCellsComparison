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

  <!-- Unit Labeling Utility -->
  <xd:doc>
    Writes the label of an unit 
    <xd:param name="label" type="string">original unit label</xd:param>
  </xd:doc>
  <xsl:template name="LabelUnit">
    <xsl:param name="label"/>
    <xsl:choose>
      <xsl:when test="$CornerNode/@Type='rel'">[%]</xsl:when>
      <xsl:otherwise><xsl:value-of select="$label"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
