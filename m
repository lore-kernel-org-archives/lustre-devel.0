Return-Path: <SRS0=r99f=PA=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFEDBC433EF
	for <lustre-devel@archiver.kernel.org>; Tue, 12 Oct 2021 01:31:14 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1D73561052
	for <lustre-devel@archiver.kernel.org>; Tue, 12 Oct 2021 01:31:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 1D73561052
Authentication-Results: mail.kernel.org; dmarc=pass (p=none dis=none) header.from=lists.lustre.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A47AE380B90;
	Mon, 11 Oct 2021 18:31:13 -0700 (PDT)
Received: from na01-obe.outbound.protection.outlook.com
 (mail-eastus2namln2014.outbound.protection.outlook.com [40.93.3.14])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EFCD5380B3C
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 18:31:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=T88Ldd/s17eUlGWSK9ZyTCYmMu9uvOlC3LP4CcuOdLizK/FFbabDrBkBMIzixVDzVKaNG3NP746xcc5Sp/FQv+ux7UJot2Gd7VsIQBRkboy2tiUK6T/aLR5Q0MxYEdO+5HXX04efnuus7z4407ZkdDIXE3UlcdLhv85vt60tk5h7RdQT3SWw+ZnsCDvkjRag1dfM8k2ayLa3Jq00lf/EII0AZL6ufDV+jJ3xa2B2vWep31GmikCMwqYJVetZDTzIVsHNNcypXUqpm5tjNVb+ywf4zU/1xF1W0vuJJzcvBd4AIQ48WDz43EyLJzf7Fx5mKHGOyD2XhzuQjCu1Cg4PeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=v4fnxkwcBQLbliYr9h9QvR2Ck3bgs3IIqF725q0u7Qo=;
 b=etDaey9WN9E77VGR9+iarxuFCGVPi/HACmA4HJE7zxjJ5c6KnDekxduE1lUCkWi+WsKs7IohSuw12H7nI5UkVjmA8ivB4fqVSSnLGZ7Et1LjuvgKAYMpJNNlXeAnn3XVInAiF/9EN9nQiDLTxnKBOcwB4echVSCzrNA92oJcoe9F2uiL3NxgiHURsvtlKtWq4PRPVlU3EQoTHBiPIYkTH7WrRmda3wxWGMN8NvYTsPlg9jcM1ITeLEiSw18f/dOxp4H/GnavhMjryg+15QbLz0Bs97ZHcRothfu0+xkhlIuuJ6sgscca8GLdc9vnli5mK1PDAdcoAAP0NQwGbT8EDw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=microsoft.com; dmarc=pass action=none
 header.from=microsoft.com; dkim=pass header.d=microsoft.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=v4fnxkwcBQLbliYr9h9QvR2Ck3bgs3IIqF725q0u7Qo=;
 b=bAUhTYKAAG2lpfNoGUYHF67iRQplzAnb8w1YOoGjB/HaW53n3tDOq6Uv2keBtmcK7yvDDFHarX5gNZKpe0wg5y1SJsp9OiMZOn6YvTgHNJ6E5CbVFhxtiqTEmNJ55fbXcyGhMGfk7u5B3wu4xx8roPbgrTfXn4zzn4Kb1Pgwzcw=
Received: from MN2PR21MB1439.namprd21.prod.outlook.com (2603:10b6:208:20a::15)
 by BL0PR2101MB1794.namprd21.prod.outlook.com (2603:10b6:207:1a::33)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4628.3; Tue, 12 Oct
 2021 01:31:09 +0000
Received: from MN2PR21MB1439.namprd21.prod.outlook.com
 ([fe80::4126:9b95:9036:6b5]) by MN2PR21MB1439.namprd21.prod.outlook.com
 ([fe80::4126:9b95:9036:6b5%5]) with mapi id 15.20.4608.012; Tue, 12 Oct 2021
 01:31:09 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: xattr stat mismatch in sanityn test 73
Thread-Index: Ade8QbQkpHtTbKGQS1SFXsTjFYA+vgCxflcw
Date: Tue, 12 Oct 2021 01:31:08 +0000
Message-ID: <MN2PR21MB1439C536D75DED3DF32C1DCBBEB69@MN2PR21MB1439.namprd21.prod.outlook.com>
References: <MN2PR21MB1439DBD46F20244F6A7A006BBEB29@MN2PR21MB1439.namprd21.prod.outlook.com>
In-Reply-To: <MN2PR21MB1439DBD46F20244F6A7A006BBEB29@MN2PR21MB1439.namprd21.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_ActionId=c436a04a-e00c-4d84-8d0a-c0aba846a555;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_ContentBits=0;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Enabled=true;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Method=Standard;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Name=Internal;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_SetDate=2021-10-08T12:40:08Z;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_SiteId=72f988bf-86f1-41af-91ab-2d7cd011db47;
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=microsoft.com;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 9a819877-9c62-44a7-ecf0-08d98d1ff7d3
x-ms-traffictypediagnostic: BL0PR2101MB1794:
x-microsoft-antispam-prvs: <BL0PR2101MB1794241EB118E5E985365E87BEB69@BL0PR2101MB1794.namprd21.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: KwC3eufY0hsoQ8YxsYHMpP5W1cWDHoch3lZ6Dnk5jKAmhcVYgjna/Qk3Ne7g7m4a3eblSDnxvQcTFFRQpRgUTFgTXA3M3X5vZ6YZTBhbi16+ZIXiTtoGoXppJWJfe3Hl0c8N1oIaZ4Zc7nP9mG8RKMAORousW8+iPGsr7AwaxKwAXv67kovv0u4JDDyGHONZqWQ5J5JwTkqdrO9+z8G6ISu0YH7LqF3ZYys6KdUz+o7q1nKXpvQ4pTLTAhm8FhiyvsQghYMbDIr2lwL022n3hXaJBG+x9Xiss+UCoqMrFeYRwvAG2/Kk8eW4SbiQt8LwJN+VzNg/VGCtTaJdEHtZBZ16PusOEfsO12OXF/ngfjaSbVZLyCewxUNeD/uASM6ppczQvCTuqMWGsxqcGi8J66Dc1VAMRaF8bIAG6XCxMQKZzLpTU8RGqq5I/pv1BmvWpct2BNVxgTqU62hQNBGxZuQ90VGMSxZZhBWzOhDUx1Uo2g05F6MxO7i+/E4OFguuxVqWSzZ+lnv1GW66K3d9P8iTVFkHUFXJyQ+4sD6HgTIpd9trukFjHSjWHEfmDXkpHp5/ePcqQsrm8ceAfFylT2Z4uWDghImSjw2a/leTJUVO6DcyuYX580JIUcfiO9aDaTUDbxnkgsscWJfnA5ToCGEozTv5XhoAr6Zs96E5obtZmhiIAr9+3ZYbRzvRkfxI7VQBjYWYB+gAOHlhZnE8FA==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MN2PR21MB1439.namprd21.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(366004)(2906002)(508600001)(55016002)(10290500003)(71200400001)(6916009)(9686003)(122000001)(38070700005)(316002)(38100700002)(82950400001)(82960400001)(8936002)(8990500004)(66446008)(66476007)(66556008)(64756008)(26005)(83380400001)(5660300002)(8676002)(33656002)(186003)(52536014)(66946007)(76116006)(6506007)(53546011)(86362001)(7696005);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?2QFrxuqLAfUsCkUnWvnsGdktrSk9Ug2fidynw+enMREeU+/OcPFAxLBcuWpY?=
 =?us-ascii?Q?0JJUTjmIyASrAozFeN8BTOexKNr+HQ93GG58GWZwBNc+p3eBShX+Po+4s58g?=
 =?us-ascii?Q?Nzg7Q9XiRHGcyirOshD6P+jukxlu8axNB2+LEnaZSVAToL5s9kNV28STG145?=
 =?us-ascii?Q?lI/qO2XwJVqUIVVzt/ODJIGgThnvKigIeIFrpKmSrZSveNzAbSGoWBo+wHIZ?=
 =?us-ascii?Q?B09kHjuvwXGwEuJK60vyHF/HQIYNBq5whqVdc/kooH794TufBlkpNhwbGuoM?=
 =?us-ascii?Q?v5oEyxneV2FonXYYYDQsVMNbN12+MOFbv1t54iYJjhT/EltQ8j/6WIqd7AYt?=
 =?us-ascii?Q?awClg9uAD1/Ow2XLmdWnHklCIO+TO+VWr2bhajvxVB+YgopjOPZm3PoFYPu9?=
 =?us-ascii?Q?+X86w2Vp+S/TkwBzvrFPXPafUpd+uTc1jhQUB7udVJBXgr/Bh/4rcP4qMqvx?=
 =?us-ascii?Q?4g6xMUGUIU5czIL/bi2qlSLDFuYo7yjx+gO6a++ekCvSLEZd+/M2MyBbEYF8?=
 =?us-ascii?Q?UOPqKbPtsMAE5R4+LPoLLRaKj30nBb/rw67m8SWXjNCuPZ6kAzoXan8et4+U?=
 =?us-ascii?Q?bqjs1QlYQa8A8reI3U/3DhobBZgG90zOAKGsXP6l3cSdRG+/iSrBDnZ+/vXQ?=
 =?us-ascii?Q?oTvCvyUsl3pJgvOyq3LvjpXMSuwhrndlETphkIe0uZw4ECEZPXVMo1gn6dVY?=
 =?us-ascii?Q?O3WI/vk0dmcCnwP77mAg/yzoSVsZMbW/7SA0tXDGCQlzbVtHosd9Qw7X/Vru?=
 =?us-ascii?Q?GPOxKycDKpAWnt5r9MDDGCRSTJX6+LxO6RUtf6HftbUL5WyDHvvjKqV3psKi?=
 =?us-ascii?Q?F0tZ7qEQxCPn1rFhvcnmlV5lQSv1fd/KhnFoiNQUsxERlnV4p+SGkCCAQkBd?=
 =?us-ascii?Q?r0ibi3oIwnZq9JGy23bt+SjMJruKrWprpR3PCQOByV4BgWKQNNkYHQjvugxa?=
 =?us-ascii?Q?Cd1hvAvMkv8mhdm4gFIhZhcDMR2YZ0TcExZqs4W0jCDpGnmhOCN0INVnVCJv?=
 =?us-ascii?Q?6KmEA18g2rj58FED5zzuG+N2t6PQ//OPYOKD4xGdJSFsmIEwnjhvO5I1RXnx?=
 =?us-ascii?Q?EUlNhBh6Fshxa9ywiy2SqshTmr8JqpbuuvqrQYTUguXn9pEjX/yDnfD6zuv+?=
 =?us-ascii?Q?7L5TLFP2GBN6OIFcVIAlYsdhg5NlCJioQKDRzKkEzEVCxfrQl1wE1u8qBI8Q?=
 =?us-ascii?Q?MWwbsK6RF2NuvGDErDkP4UxhMVeKy4tkDCQxeQqXQIz1bGzdbvUMKFrAKdSP?=
 =?us-ascii?Q?E7TN8AFLNSMqQruuMSAlMUq6W1P+qxwNluKYErKAOPO7MTaWVsxZHLUYg/bX?=
 =?us-ascii?Q?S0UpLXZdH+/fLZzH3dQ7H0DSLPnfuYFj9oMcdtCbHqUiPv95KxJ8XrWksaKM?=
 =?us-ascii?Q?09DSNCCq62PMtL6FFulTNsu3JVudkBYeL/jH7MlHsIo1VRkLDhNVqew7bFFP?=
 =?us-ascii?Q?6cD3H4fcADjgnU3UrKWjI7zdZnDtJV3aOOP5wzTP4lurvWGt4e/H4C7vKGMP?=
 =?us-ascii?Q?rtcyQ5HfqiYxKWTb5DWdcpIFeqOHEmBs+uyoG/3VTe6EpKdRq5yYusk5aV7D?=
 =?us-ascii?Q?R7RJBNuoUJ0E3JBH6kVsfvcppOQgpTCS/cZ+tUnsLj9xqOUK5SqkIZrd7Gl6?=
 =?us-ascii?Q?Yg=3D=3D?=
MIME-Version: 1.0
X-OriginatorOrg: microsoft.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MN2PR21MB1439.namprd21.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 9a819877-9c62-44a7-ecf0-08d98d1ff7d3
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Oct 2021 01:31:09.0003 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 72f988bf-86f1-41af-91ab-2d7cd011db47
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: XG8lLnbRYmfytcnn0OoGttsBkaBu+Ics/XeadPZjpNf/wDVQ5IVKXVsk7nJkInYW6z7VYiKo3Ha4R2Q6NVqCjy9BGZ+Gn8/sCUQJGCcJaKI=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BL0PR2101MB1794
Subject: Re: [lustre-devel] xattr stat mismatch in sanityn test 73
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
From: Ellis Wilson via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Ellis Wilson <elliswilson@microsoft.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Apologies if somebody responded and it got spammed or I missed it -- in any event I got to root cause and figured I'd answer my own questions in case somebody went looking.

The additional three getxattrs are caused by inode audit code in the kernel, which is triggered if there are any filesystem specific rules in-place (e.g., log to audit file if directory /etc/auditd is modified).

You can see the additional stack traces with eBPF stackcount:

  ll_xattr_cache_get
  ll_xattr_get_common
  __vfs_getxattr
  vfs_getxattr
  getxattr
  path_getxattr
  __x64_sys_getxattr
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  [unknown]
  [unknown]
    getfattr [19698]
    1  

  ll_xattr_cache_get
  ll_xattr_get_common
  __vfs_getxattr
  vfs_getxattr
  getxattr
  path_getxattr
  __x64_sys_getxattr
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  [unknown]
  [unknown]
    getfattr [19698]
    1  

  ll_xattr_cache_get
  ll_xattr_get_common
  __vfs_getxattr
  get_vfs_caps_from_disk
  audit_copy_inode
  __audit_inode
  filename_lookup
  user_path_at_empty
  vfs_statx
  __do_sys_newlstat
  __x64_sys_newlstat
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  [unknown]
    getfattr [19698]
    1  

  ll_xattr_cache_get
  ll_xattr_get_common
  __vfs_getxattr
  get_vfs_caps_from_disk
  audit_copy_inode
  __audit_inode
  filename_lookup
  user_path_at_empty
  path_getxattr
  __x64_sys_getxattr
  do_syscall_64
  entry_SYSCALL_64_after_hwframe
  [unknown]
  [unknown]
    getfattr [19698]
    2

Only the ones without "__audit_inode" in them are doing "real" work.  The remaining three are simply performing getxattrs against the path being operated on as part of filename_lookup for audit.  So long as auditctl shows enabled AND there is at least a single rule that relates to the filesystem (e.g., audit all modifications to /etc/audit), every single lookup will result in a get(x)attr to get VFS caps.  Relevant call path through the kernel is:

filename_lookup
audit_inode
__audit_inode
audit_copy_inode
audit_copy_fcaps
get_vfs_caps_from_disk

Disabling auditd completely via auditctl -e0 returns the total number of getxattrs to the expected value of 2.

Overall, the check in-place for this test is arguably too overfitted.  At some point I'll put together a PR such that the check is assuring there are at least 2 getxattr_hits rather than exactly 2 unless somebody objects to that solution.

Also, I found maloo and got an account so I could review upstream unit test results.

Best,

ellis


-----Original Message-----
From: Ellis Wilson 
Sent: Friday, October 8, 2021 9:04 AM
To: lustre-devel@lists.lustre.org
Subject: xattr stat mismatch in sanityn test 73

Hi all,

I'm trying to get to the bottom of a failure I'm seeing while running the lustre unit tests, specifically here for this test in the sanityn suite:
= sanityn test 73: getxattr should not cause xattr lock cancellation =

I'm running stock lustre 2.14.0 on Ubuntu 18.04 with Linux Kernel 5.4.0.  I have six nodes total for the test: two clients, two mds, two oss.  The test is running from one of the clients.

The error I get is:
============
getfattr: Removing leading '/' from absolute path names # file: mnt/lustre/f73.sanityn user.attr1="value1"

ELLIS: expected 2, but got 5
 sanityn test_73: @@@@@@ FAIL: not cached in /mnt/lustre
  Trace dump:
  = /usr/lib/lustre/tests/test-framework.sh:6273:error()
  = /usr/lib/lustre/tests/sanityn.sh:3557:test_73()
  = /usr/lib/lustre/tests/test-framework.sh:6581:run_one()
  = /usr/lib/lustre/tests/test-framework.sh:6628:run_one_logged()
  = /usr/lib/lustre/tests/test-framework.sh:6455:run_test()
  = /usr/lib/lustre/tests/sanityn.sh:3567:main()
============

I've instrumented the code to spit out the expected vs. discovered stat values.  The failure indicates the file in question wasn't cached, but in fact the inverse is occurring -- it's both cached and hit more often than expected.

The unadulterated test code follows:
================
3549     touch $DIR1/$tfile
3550     setfattr -n user.attr1 -v value1 $DIR1/$tfile ||
3551         error "setfattr1 failed"
3552     getfattr -n user.attr1 $DIR2/$tfile || error "getfattr1 failed"
3553     getfattr -n user.attr1 $DIR1/$tfile || error "getfattr2 failed"
3554     clear_stats llite.*.stats
3555     # PR lock should be cached by now on both clients
3556     getfattr -n user.attr1 $DIR1/$tfile || error "getfattr3 failed"
3557     # 2 hits for getfattr(0)+getfattr(size)
3558     [ $(calc_stats llite.*.stats getxattr_hits) -eq 2 ] ||
3559         error "not cached in $DIR1"
================

The failure occurs on line 3558.

Manually performing these actions validates that indeed the jump is by 5, not 2:
~# lctl get_param llite.*.stats | grep hits
getxattr_hits             85 samples [reqs]
getxattr_hits             4 samples [reqs]
~# getfattr -n user.attr1 /mnt/lustre/f73.sanityn
getfattr: Removing leading '/' from absolute path names # file: mnt/lustre/f73.sanityn user.attr1="value1"
~# lctl get_param llite.*.stats | grep hits
getxattr_hits             90 samples [reqs]
getxattr_hits             4 samples [reqs]

I straced getfattr as run in the test and found it issues the following:
23262 lstat("/mnt/lustre/f73.sanityn", {st_mode=S_IFREG|0644, st_size=0, ...}) = 0
23262 getxattr("/mnt/lustre/f73.sanityn", "user.attr1", NULL, 0) = 6
23262 getxattr("/mnt/lustre/f73.sanityn", "user.attr1", "value1", 256) = 6

I built a small C program to replicate just the above without all of the other fluff in getfattr, and I see 1 xattr cache hit occurring for the lstat, and two xattr cache hits occurring for each call of getxattr.  So it replicates the 5 xattr cache hits.  It is notable that if one does NOT specify "user.attr1" and instead just uses an empty string you only get a single hit on each getxattr.

I have a patch that revises the expected stat values from 2 to 5 and from 4 to 10, and while that works in my system I wanted to know:
1. Are these changes expected?  I don't know much about the xattr cache or when it's expected to be hit, but hitting twice for a single getxattr seemed high.
2. Is there any location online where I can look at release testing results for these unit tests?  I wanted to see if I was alone in hitting this many times, but couldn't locate such a repository of historical test results.

Thanks for any and all help!

Best,

ellis
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
