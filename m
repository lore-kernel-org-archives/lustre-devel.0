Return-Path: <SRS0=xKfM=O4=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 791C8C433EF
	for <lustre-devel@archiver.kernel.org>; Fri,  8 Oct 2021 13:04:20 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E738760E94
	for <lustre-devel@archiver.kernel.org>; Fri,  8 Oct 2021 13:04:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org E738760E94
Authentication-Results: mail.kernel.org; dmarc=pass (p=none dis=none) header.from=lists.lustre.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8B49F21E070;
	Fri,  8 Oct 2021 06:04:19 -0700 (PDT)
Received: from na01-obe.outbound.protection.outlook.com
 (mail-eastus2namln2013.outbound.protection.outlook.com [40.93.3.13])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0E8F221E020
 for <lustre-devel@lists.lustre.org>; Fri,  8 Oct 2021 06:04:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=efmXV7sCMeGWNX2gYdCu/3RLAvTC3+N8M45iziBUVhqi0wABjKZWLTs82wC4vMNOnd7DYeAjD8orSFXukjHc1aiT7vZ/SdbDzFOLBKAy96ioszx484BE+MzZ+OeQd0c/kto7kQSdOrfgtGX310CDz4i0NJm9lzkfYpY41JFwZG2pVZFcBGMSdkvFR3PAaVcUfUNqaVcwB8ufz3zlQwiyfQ6Q0D3obI1gRiV5WgWHeHrqBVqxLIGGaOm3NP/z5GdGf7p0TZhy+C3CNQYqPu2ywmOnbAzvYAkuApPtq67NyIlx5Y67TipQIDdy+6lxGz9Yg9QkRitIyT88YrIKpWCNFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=ZNoS3/WEf7DkCujZAHLTaARO5703v1A4bOWrMCt1aZM=;
 b=IybMBEY7DWBF2Mg1rb4t3IyRdCOUa2wb+5zTqDjewLzYuo77ZYtZlCQXUP26Ohk+XWfGgkW7y//hEDxX6v4tPh+agfPOgDhYWlewO1AP0x/d7X80QEKo+FvwrXhcFsFXvKOALyHF5KqnF+zssZ7muRjjVRt1PDaxbuUoYuk4Dtq7X3leFogTApQtK8UTsdIG4OH8xjqX0G6Drvmsyb3HC5DryWCjbrPfhEep+z6IUTMhmFJ8UssoNhU5AaRHAmB6p2vJk/jWLmx22V2IMKWng/ilz1hWt+A/+fQhZgRz2R40NvznCkWro5/EcdFdRfx7UDqcOdeTkycSSHLw6hPxsw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=microsoft.com; dmarc=pass action=none
 header.from=microsoft.com; dkim=pass header.d=microsoft.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZNoS3/WEf7DkCujZAHLTaARO5703v1A4bOWrMCt1aZM=;
 b=f7eIkN8qwuWTwrv4pWW6OvMKOyfFNYWI1iajwQgnWUOviT/VC524FARmnzc6mf/HxzTVs3aVnvocCBirFMVajUi3+LAk9R3S++rSn/L+KCkPIKzAcOHMjKhH6jikYj95C2zUpQrd08MMzCygFzFAcPjEvFVzErBE/ehIx7yXUAo=
Received: from MN2PR21MB1439.namprd21.prod.outlook.com (2603:10b6:208:20a::15)
 by MN2PR21MB1407.namprd21.prod.outlook.com (2603:10b6:208:204::18)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4608.3; Fri, 8 Oct
 2021 13:04:15 +0000
Received: from MN2PR21MB1439.namprd21.prod.outlook.com
 ([fe80::4126:9b95:9036:6b5]) by MN2PR21MB1439.namprd21.prod.outlook.com
 ([fe80::4126:9b95:9036:6b5%5]) with mapi id 15.20.4608.008; Fri, 8 Oct 2021
 13:04:14 +0000
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: xattr stat mismatch in sanityn test 73
Thread-Index: Ade8QbQkpHtTbKGQS1SFXsTjFYA+vg==
Date: Fri, 8 Oct 2021 13:04:14 +0000
Message-ID: <MN2PR21MB1439DBD46F20244F6A7A006BBEB29@MN2PR21MB1439.namprd21.prod.outlook.com>
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
x-ms-office365-filtering-correlation-id: b15b8dc2-d385-40ce-421c-08d98a5c2145
x-ms-traffictypediagnostic: MN2PR21MB1407:
x-microsoft-antispam-prvs: <MN2PR21MB140758320B83FC2900A069B7BEB29@MN2PR21MB1407.namprd21.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: u2+TZUJNvk2tCVNUduikOUxKLO24Lc50HySfN8VBxHuAJDVXcNK9iXI433+MZlZbZP8u2xKAKIx7FuEyx9uV3/Rw1dIaJJyUJg6Sfz0Hkvo7Veqzxp0wc2x2UaS6fCxK+GL6fCcbxY2ThRgwUn+CrU/wddYCag5V2wbRja6q56BZsoWDBTz5lqk0m4Lm/UkADQCvQHh/QHwSuoYfLA2fED98RDjHCJszsN3foQVz1HW8+DhInRrt1TAttywx6mpljjp+/5IVAGXPHaltdy3go9Ec8/ybT4mYQA9ziXwS8Bgi4W/TBZpitdIePB7gMNp82NXKrqBzfbL7lgocMUgbPD8S6vhn36l3HkA/h7vjqT8xlPlJuKAj3LR9H8yL4HzMqx/s7cMTrgm5oa9gilbIhLVZHA25Mga/SymYnJMHnR2/wifkjC6RSizK6culs9VqW1N1Y6QqyXwYx4UdJWDt2rnySkm1/LjdlAn28xKO88aQYdfh0ybaayPgnZGHzwW16rBdugsYVO7UcH1KT/DE/PC8WAr8+ulNia2POsQdvh3gv75XIRb2W8Q+7qB1HIM5XAQiz3Jcnb4okluWDQqjidatOe4nn20JKnIolUhR5zjT3PbVCURTetKzjHngjgPHEugdAFzc5qT3LcZk3EK2qpEOxl2IlpCQFDylZSLkQ+15JbVhVllx0e8NEKETA6+tnFqbTIZ76OXAcDP1YNKzMQ==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MN2PR21MB1439.namprd21.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(366004)(66556008)(64756008)(71200400001)(33656002)(8936002)(66476007)(55016002)(8676002)(5660300002)(2906002)(7696005)(76116006)(38070700005)(9686003)(66446008)(66946007)(186003)(8990500004)(26005)(86362001)(10290500003)(122000001)(38100700002)(316002)(82950400001)(82960400001)(508600001)(52536014)(83380400001)(6506007)(6916009);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?baejiZ4KidZWK5IB85QZxR7RGF8NYww9YZdidEZ/BD2/AixgYPyr7en6LZ9B?=
 =?us-ascii?Q?X2+SagisVSsCQraLZeJPRrL+nVNDUave6UcsbyvpDe9I8tvXQP5VDDDhd12X?=
 =?us-ascii?Q?YpkvbOQmMpjMuoBzyJSjtwUNUJL69dSXELjMInat6l4q9iRjM8rW6+ZPEXsT?=
 =?us-ascii?Q?vRbMhmyKVmHO90Ct7ai3iAfYEmbX2J9vmM2vgzOdUmY4Q1NPBnTKux8UYpNt?=
 =?us-ascii?Q?T/QRhVS10bxWxuXi/D2k2Jb2Of7t7lwquLveSdDaikq6NL/OlYza7GLTcUCD?=
 =?us-ascii?Q?ElLE4bSSBlHmXdchgRtWtW+l2QCj/J17GhTTjMWnpdnsWoK4V0MFPszGjGVH?=
 =?us-ascii?Q?HQV+K3nsZPvkufiIXWrgf+WrLu2pdRbfsOhwNjGJEiJGtbtTqEwbf+Tti/5/?=
 =?us-ascii?Q?DAOmeFQArPf0mcmqX2mRwtDuZBSzyiQfJ+Y4D4/H7HNX+qp/S4I7VlnsTiMs?=
 =?us-ascii?Q?EODDpzAiJ14v1xdFQsZzdgx+eQbtgoxzXPNCVKrxPvfxmv+pXPrt26YlVEpB?=
 =?us-ascii?Q?eLWKDRG/a3PAMPLv0Fc7BkmtQOMP+tNglPShoH/4OcuSwWgkUkh3K7QOTJEj?=
 =?us-ascii?Q?34mHDWzmgnKdJojt/1hS7tjnv2/9vANmLMYyvEs5zaDfVCEef0U6VdAZlxPy?=
 =?us-ascii?Q?FHYnlue+1x2DXpcPyjUbNAVOn4YH9dMImjlWkxNt7JoV7iwPBubKD3Uu/M7P?=
 =?us-ascii?Q?Gh2csHsL5mZ//oayDfNBEux1bm/fn3c1PCijxw2NgHgQNjsE6L6RdVfCV9fr?=
 =?us-ascii?Q?Lh/PxDNQzG/BJv2+qjbJQkFyl0nEOvDs5rhjzRKqsMXKZXtZFO1bI6n8DW0w?=
 =?us-ascii?Q?gzAHwZ3AmaPMyGsr/hCQZglOjepd9LFcXH6H8dUnQnaqWt8YkGqIJyr+UsXo?=
 =?us-ascii?Q?WDmUA3obR2K1jcD4iEMhOhXv4i9eNwk3c6IFggk0ebZVEJygmSFH0GbQkiOj?=
 =?us-ascii?Q?ScE/+bjpd21J9y40jsUIQIvgDHMtNInCEv/riIIzfoYOwPaQ+ay3JsKuCuWk?=
 =?us-ascii?Q?SLWa/4XC1bg5gm1V2hiiVVwtKtP5QYUW2bvi8dKdyzpnyoho5ngAAMLzT3Oe?=
 =?us-ascii?Q?B641qiFwYTCcaT5D0OfEGxjfyNwA8+L2e5ADs6ivSRJoJrf30h1iqAFtYNj5?=
 =?us-ascii?Q?xKg3uUxLsWWVqrJlRZZWT0dv/luF9HgA6n4P1jHh9SgDycl51m9dR+16wGqX?=
 =?us-ascii?Q?WOCgHwVcCZdmsdXTKw9x9xuoIF8sYtahq/URCkyWQ4KzG8mAbu5hdvUea9g?=
 =?us-ascii?Q?=3D?=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-OriginatorOrg: microsoft.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MN2PR21MB1439.namprd21.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b15b8dc2-d385-40ce-421c-08d98a5c2145
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Oct 2021 13:04:14.8650 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 72f988bf-86f1-41af-91ab-2d7cd011db47
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 6ucpfc7PwNqALTIuMW/yAC/ja89jmRGAARobFG+jUyHpcUVHEWjLpa0GMNtZehhM3QGLXo6OhenjZs7xs7PMf3SHnSOWWKj+OAyvraO5F/g=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR21MB1407
Subject: [lustre-devel] xattr stat mismatch in sanityn test 73
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

Hi all,

I'm trying to get to the bottom of a failure I'm seeing while running the lustre unit tests, specifically here for this test in the sanityn suite:
= sanityn test 73: getxattr should not cause xattr lock cancellation =

I'm running stock lustre 2.14.0 on Ubuntu 18.04 with Linux Kernel 5.4.0.  I have six nodes total for the test: two clients, two mds, two oss.  The test is running from one of the clients.

The error I get is:
============
getfattr: Removing leading '/' from absolute path names
# file: mnt/lustre/f73.sanityn
user.attr1="value1"

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
