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

function tBr(branch){
  var objBranch = document.getElementById(branch).style;
  var obj = document.getElementById('I'+branch);
  
  if (obj) {  
    if (objBranch.display=="none" || (objBranch.display=="" && document.getElementById(branch).getAttribute('hide')=="true")) {
      objBranch.display="block";
      obj.innerHTML = '<img border="0" src="'+openImg+'"/>';
    } else {
      objBranch.display="none";
      obj.innerHTML = '<img border="0" src="'+closeImg+'"/>';
    }
  }
}

function oBr(branch){
  var objBranch = document.getElementById(branch).style;
  var obj = document.getElementById('I'+branch);
  if (obj) {
    objBranch.display="block";
    obj.innerHTML = '<img border="0" src="'+openImg+'"/>';
  }
}

function oBrs(branch, parentTag){
  oBr(parentTag);
  oBr(branch);
}

