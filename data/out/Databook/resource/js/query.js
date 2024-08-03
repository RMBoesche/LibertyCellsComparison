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

function queryString() {
  var query = window.location.search.substring(1);
  queryFromString(query);
}

function queryFromString(query) {
  var parms = query.split('&');
  for (var i=0; i<parms.length; i++) {
    var pos = parms[i].indexOf('=');
    if (pos > 0) {
      var key = parms[i].substring(0,pos);
      var val = parms[i].substring(pos+1);
      if (key == "elem") {
        highlightPageElements(val);
      } else if (key == "colHide") {
        columnHide(val);
      } else if (key == "rowHide") {
        rowHide(val);
      }
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//  End of file.                                                              //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
