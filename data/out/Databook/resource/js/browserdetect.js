////////////////////////////////////////////////////////////////////////////////
///                                                                            /
///                   Copyright (C) 1984-2023 Silvaco, Inc.                    /
///                            All rights reserved.                            /
///                                                                            /
/// The Silvaco name and the Silvaco logo are trademarks of Silvaco, Inc.      /
/// and/or its affiliates ("Silvaco"). All trademarks, logos, software marks,  /
/// and trade names (collectively, the "Marks") in this program are            /
/// proprietary to Silvaco or other respective owners that have granted        /
/// Silvaco the right and license to use such Marks. You are not permitted to  /
/// use the Marks without the prior written consent of Silvaco or such third   /
/// party that may own the Marks.                                              /
///                                                                            /
/// This file has been provided pursuant to a license agreement containing     /
/// restrictions on its use. This file contains valuable trade secrets and     /
/// proprietary information of Silvaco and is protected by U.S. and            /
/// international laws.                                                        /
///                                                                            /
/// The copyright notice(s) in this file do not indicate actual or intended    /
/// publication of this file.                                                  /
///                                                                            /
////////////////////////////////////////////////////////////////////////////////

function verifyBrowser() {
  var browserOk = false;
  var browser = '';
  if (navigator.userAgent.indexOf("Firefox") != -1) {
    var versionindex = navigator.userAgent.indexOf("Firefox") + 8;
    var version = parseInt(navigator.userAgent.charAt(versionindex));
    if (version < 3.0)
      browser = 'ff2';
    else
      browser = 'ff3';
    if (version >= 2.0)
      browserOk = true;
  }
  if (navigator.appVersion.indexOf("MSIE") != -1) {
    browser = 'IE';
    var temp = navigator.appVersion.split("MSIE");
    var version = parseFloat(temp[1]);
    if (version >= 7) //NON IE browser will return 0
      browserOk = true;
  }
  
  if (!browserOk) {
    body = document.getElementsByTagName("BODY")[0];
    body.innerHTML = '<p class="comment">Better visualized with '+
      getSupportedBrowsers() + '.</p>' + body.innerHTML;
  }
  return browser;
}

function getSupportedBrowsers() {
  return 'Firefox 2.0+ and IE 7.0';
}

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//  End of file.                                                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
