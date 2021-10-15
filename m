Return-Path: <SRS0=oOak=PD=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F654C433F5
	for <lustre-devel@archiver.kernel.org>; Fri, 15 Oct 2021 14:25:42 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C9CFB610E5
	for <lustre-devel@archiver.kernel.org>; Fri, 15 Oct 2021 14:25:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org C9CFB610E5
Authentication-Results: mail.kernel.org; dmarc=pass (p=none dis=none) header.from=lists.lustre.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 88DA921F1CD;
	Fri, 15 Oct 2021 07:25:37 -0700 (PDT)
Received: from na01-obe.outbound.protection.outlook.com
 (mail-eastus2namln1003.outbound.protection.outlook.com [40.93.3.3])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 23DDD21E008
 for <lustre-devel@lists.lustre.org>; Fri, 15 Oct 2021 07:25:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=HrS4hMSfV3pNPVCxDi006+Wks2jCNZsGRJHSCZpJVuQ7OvIN75eT05muci+avYva1YbG9v/itRTqlhwwpEwS4KqxKUtTJMGRBsOjsqctBtbX5uwsQAAZnaVFahfkW/zMnHoKpwcWjt/PcudeJftSvEDL/UGRpBA1zyNHCs833hsxDxAjmc2+GVyftTYPNPfttim6z7YqJdizhxpBq5/qAUlPeBd+99ymOzIfY0xqq8JjOyYJkzvxEFsfzc+Poa/E68z+tiIlmvc1YLucSdusZfnlJk+W3B67vy+ydEIj0RgBcuxQACNLOzg34QArKuwkvjib7DRehlQNF2y6jvTkHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=ZkVPk82onu51USy82wIsRla/TGYEVHDeiAxQF+4MVvU=;
 b=Yy73ryF8SppkS6apREhfH+Ex2tooYRs3pGc4xy93IwLJ0znpAqQWf0lak/3cWVhAQb+Y3SyNNt1WlllaOtMR2irZIZ0QySyDmgz81b2Dcti+91k5T2OlwsKMqbL3BbqjSQJg+Bp/jNMccdQhAfg6NbYfV+pEpj8/LgkIyF5D7H/NaCelkSHtfFpmRm3LnGxJiGEzoZVorRFvKHrN+Z+0lhZMSJcGGC0qgs6pfYBn57sgon+J8Ciilo5Xx/f7ti5pnFas4rQIDJnAC8e4MQzMCywQvJ47K7UWTzXBaB7P+CHR+Vw5iwlc3MVUul3YiDSGBXe3eG4qjtzmAUVduRKp+A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=microsoft.com; dmarc=pass action=none
 header.from=microsoft.com; dkim=pass header.d=microsoft.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZkVPk82onu51USy82wIsRla/TGYEVHDeiAxQF+4MVvU=;
 b=i0jfpoOSDcuLjnOYAyZhTlEsAXw4jtjbojC9TROL/HGC4wqYiPSXSnFHwk72UKfB2ihqnWmV7RfkSdLHWJL6iwuN3X2LMogE+7NDyPHI51P6b8XydSxXcsldMpzp4tIiV1CNnpAT1E5GlrLciRbiyauyncidQKsPUon7dgnz6pA=
Received: from MN2PR21MB1439.namprd21.prod.outlook.com (2603:10b6:208:20a::15)
 by MN2PR21MB1472.namprd21.prod.outlook.com (2603:10b6:208:20b::24)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4628.3; Fri, 15 Oct
 2021 14:25:32 +0000
Received: from MN2PR21MB1439.namprd21.prod.outlook.com
 ([fe80::8401:4975:913c:fd00]) by MN2PR21MB1439.namprd21.prod.outlook.com
 ([fe80::8401:4975:913c:fd00%6]) with mapi id 15.20.4628.011; Fri, 15 Oct 2021
 14:25:32 +0000
To: Andreas Dilger <adilger@whamcloud.com>
Thread-Topic: [lustre-devel] xattr stat mismatch in sanityn test 73
Thread-Index: Ade8QbQkpHtTbKGQS1SFXsTjFYA+vgFSs5gAABDI+sA=
Date: Fri, 15 Oct 2021 14:25:32 +0000
Message-ID: <MN2PR21MB1439B848E85A1275B8711B43BEB99@MN2PR21MB1439.namprd21.prod.outlook.com>
References: <MN2PR21MB1439DBD46F20244F6A7A006BBEB29@MN2PR21MB1439.namprd21.prod.outlook.com>
 <7947C4DF-8BEF-4AA9-8EFE-C3679EAFE252@ddn.com>
In-Reply-To: <7947C4DF-8BEF-4AA9-8EFE-C3679EAFE252@ddn.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_ActionId=febec941-7a26-41be-944f-4bd7e34a7369;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_ContentBits=0;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Enabled=true;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Method=Standard;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_Name=Internal;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_SetDate=2021-10-15T14:19:22Z;
 MSIP_Label_f42aa342-8706-4288-bd11-ebb85995028c_SiteId=72f988bf-86f1-41af-91ab-2d7cd011db47;
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=microsoft.com;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 9c30a477-e055-4817-e060-08d98fe7a59b
x-ms-traffictypediagnostic: MN2PR21MB1472:
x-microsoft-antispam-prvs: <MN2PR21MB147290BAF151121C4F6B9CA1BEB99@MN2PR21MB1472.namprd21.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: Z9iyI80bJUUo0VWO0EBaw/XrwhitBl7V1LJoRdO+tyhO7QZM5RSL/TOiJRQ825RwNuG48byXxm9swxXhRkJ2oQJpjVN2cr+QdheF82t9IRUaHglgZXDZvqjYtBGX7Xp0xibG7d/xGSjkV0beoUm2fzmXklGtS4jN3/9eg2zVPhcSXjsxZRt+ft9dqgE3COy79mMn9JF8GtgAeV3R/OkZ77o0F0niaf+X15qTMpo0t6YuYnF43iXPQmQg/dJBGCKLpMKjku3cpcRaRKDW1FmAdzPM9TMQPuBF+kff5F0Vdkn5Vw+NyiVSNZ7lNHXqosF4CFgQ9H+kPBLMZFelS3xoqiCCt/hlpr6IkrMyAK5JD4ZRCn5GsS+6mn/+AsOH60A1i0itM5/sxBb3MpaWCo4PGBEwbYmZoi2GNvIvTA8e4wU+ZYXdlR1UxqfGgz/agBEwgvmaX1zVXYS+XWAIDv4ANIBPjFHsMWz3nSEFM7Yvxsb8iYX5ur3T4xCweL6CFgBiPdwf/iexlLuiXX5CWKBgh4pZm5pPMJxffr4UsuXU7sHKXuvxmcYNsqUo0X6Ob2xCHFIQMV1xXAebeR4wM1mi+zOilyIZTnW3qoA2dGV7k1ZE/nkQ/+ieAaFkOBie//t/1GN2qRUG4ScB/NWKZI8wGEGag8Fxoexmx3qVN2oNRassIkHKBqxRJg6fptjVchplWfqb5CvLoDU8rCTSpNAxbB4YqsaXRL9ACNe1ryl7JKs=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MN2PR21MB1439.namprd21.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(366004)(33656002)(66476007)(38070700005)(316002)(64756008)(53546011)(76116006)(9686003)(6506007)(66446008)(86362001)(66946007)(9326002)(508600001)(6916009)(52536014)(55016002)(83380400001)(66556008)(5660300002)(7696005)(4326008)(186003)(26005)(8936002)(8990500004)(2906002)(82960400001)(122000001)(38100700002)(82950400001)(8676002)(71200400001)(10290500003)(13693001);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?uf6qBA0N4k3uNJt21PQtn4+iXT4+rO09/FWJfOPugHe6SOuHpwOLVmtWffO2?=
 =?us-ascii?Q?xEtrnaMKFsckjkDHurkExQt6eUXH6m/rlVsCN4RGtbE+o+53l6J8Iw5LgmJU?=
 =?us-ascii?Q?g/jLvHe+zK1BYfRienf416anDsKr3MczcYA85/amMFnN6Ci4ysLYlrVVaj4p?=
 =?us-ascii?Q?D+/uq6BSGvHRGCMyYlPNCrLfZD2PGdZgZIkC/3aU3HYz2cIeaH0JhvcKxh3x?=
 =?us-ascii?Q?hA3rD/fBXdt7RthPzu+Y2wv3Wbmkn10kz8HuPdsEMq37AJ4RYDgNDv4tjhmg?=
 =?us-ascii?Q?FpWMO+b23SRHutfVNY+qSNppr6Y62J2uBCyKyYJXl8MA14mDBU042hCFL6xE?=
 =?us-ascii?Q?DuHQR7Z5DQXxf34IZ9knhQKl2j0hGoVWKm/wKdYy5BNMC/ruljN/cdFM9rrD?=
 =?us-ascii?Q?QhXIEMbNA0Ob60ZH9j8fVIvE/isCxfkmN7zhtOKnUMvYOAvTUQiHfivZWSO8?=
 =?us-ascii?Q?7XLEbu2QT+G97PLRx21txKVNamuZ4J0FbZOYPHcrN2QrAZ5VsCO3HIYphUKK?=
 =?us-ascii?Q?9zTaKDK2j00cb0b98PXy9ksi7LpiL9bnK5HdtJHKI8rgqgEmnvcES4D1El5t?=
 =?us-ascii?Q?Qaa8fOWjAcRpzyqb6gAKrZ+jYuE9RJvlAwJ+0eVOz+4U+Qtp/AC31EM/8DmN?=
 =?us-ascii?Q?CZEX6mqh9EhEfqANOcxgeWXsM6lzlaonHoAIbzN/NkJ0sYsb/lNLKdO3muWE?=
 =?us-ascii?Q?t7jFnBzl2kjhyO3eT6jf2enKs10LlQdsiozQt7gzfZNmJDj/PlrhlqxPH8Ky?=
 =?us-ascii?Q?Spo+AWLwNWvyK2um3QbrBmxLrCrEbl4rOxWFfJWDZgJ5iysi2s+3C4j1tcyd?=
 =?us-ascii?Q?QOPqPX7kR0NL72SFOMpScYzJIrShbydMZ11YqrnkYkJLJimlgup5th9D/cYY?=
 =?us-ascii?Q?Y1+eu6wjyXcuLfqmtZaR2mXGKqsWveeiryIf/+uvJuhi/0QQi9BbCqJdMQ+O?=
 =?us-ascii?Q?XAhdeB/y7UFCqb+13D5pmLVeYIHrxVQdauCLCCl6NQiq5CfXbjmXfPZkdpXK?=
 =?us-ascii?Q?l3pAH5//byjuTrVP58GGZBJAHDGgysLb6zW0RB/b2AHOyQpKdRVhuYacwtWw?=
 =?us-ascii?Q?REfCEBpIjgXHkV76Y9wU2I5KnG7JJc5nHIxNx5r11q3Knij3eQ8a4Bu5cVg6?=
 =?us-ascii?Q?1QTeltMQGECucfPHGxk3eVYMiB+RiWv/IYeUIBkvz1BEMkQUSUiGPwlMkq92?=
 =?us-ascii?Q?gRAyoUFT7GyDOne2n3fry+rvlzat5x6fom1fFWF6kIFnT+nN1x+Ft3hiVzqn?=
 =?us-ascii?Q?hk1Xvg1QltMqnlsjlCJ/OactkjDjK7AGmNfJyCBY8z0AD/j2b7+q59tQPdEt?=
 =?us-ascii?Q?cHD/1VXF4JmUMTaHORmwJjrUfpJgghArPDEnQJ2jMzCd+TKk9wPDGHZHdafN?=
 =?us-ascii?Q?svF8HsKPqbJkJmEJMuhMefMAyTy+kJhU5WUiR2WrNBqZ0st671HWp5/gK8vz?=
 =?us-ascii?Q?dhvG+nCzawwU+OxAiFGmfZXrIP9JaOk+J00k6gMtxKiCN3Zo5eeEoUC5JAmY?=
 =?us-ascii?Q?V59MrQi1879BPUx9JstBxpx7Ft2mCFh2wJswhjYO7M4fcLu1gi3myh7w8sz8?=
 =?us-ascii?Q?TWK02MAZMkAWABPbhtlt9lmUEa8jWwaWshAi0Pe8HFJgGfnkpcw2CgvUznN0?=
 =?us-ascii?Q?dw=3D=3D?=
MIME-Version: 1.0
X-OriginatorOrg: microsoft.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MN2PR21MB1439.namprd21.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 9c30a477-e055-4817-e060-08d98fe7a59b
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Oct 2021 14:25:32.7502 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 72f988bf-86f1-41af-91ab-2d7cd011db47
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: rq+lPF7sMsxZcZgvew2KIuYDkac4s+PGE8RttcfYePmdVJ74juUBeMVSjqyMWL4kBMa7BeDkkjs+yFAC2phHUj2LhFxBmJE4jHSHRiIIRuc=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR21MB1472
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============7299337125331426874=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7299337125331426874==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_MN2PR21MB1439B848E85A1275B8711B43BEB99MN2PR21MB1439namp_"

--_000_MN2PR21MB1439B848E85A1275B8711B43BEB99MN2PR21MB1439namp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi Andreas,

Yea - I noticed that.  What makes it even funnier is that it makes allocati=
on calls in statically defined chunk sizes, so it's not even like it's exac=
tly the right size in truth.  If you look at my follow-up email you'll see =
that I RC'd this to auditd mechanics in the kernel, which was enabled on my=
 system.

I'm going to open a bug and submit a patch for the test to be more forgivin=
g for test systems that have auditd enabled next week.  In short, it will a=
ssert that it saw at minimum two getxattr hits, rather than exactly two get=
xattrs hits.  That's behaved well for me since I revised it locally.  Let m=
e know if you see any issue with this simple solution.

Best,

ellis

From: Andreas Dilger <adilger@whamcloud.com>
Sent: Friday, October 15, 2021 2:19 AM
To: Ellis Wilson <elliswilson@microsoft.com>
Cc: lustre-devel@lists.lustre.org
Subject: [EXTERNAL] Re: [lustre-devel] xattr stat mismatch in sanityn test =
73

Ellis, the getfattr code has a poor "optimization", in that it first calls =
getxattr(buf=3DNULL, size=3D0) to have the kernel report the xattr size to =
allocate a buffer of exactly the right size.  However, IMHO while this avoi=
ds a "too large" allocation (maybe a few bytes vs. 64KB), it is inefficient=
 by doubling the number of syscalls into the filesystem.

The other getxattr cache hit during lstat() is likely because of the kernel=
 accessing an selinux/security xattr.


On Oct 8, 2021, at 07:04, Ellis Wilson via lustre-devel <lustre-devel@lists=
.lustre.org<mailto:lustre-devel@lists.lustre.org>> wrote:

Hi all,

I'm trying to get to the bottom of a failure I'm seeing while running the l=
ustre unit tests, specifically here for this test in the sanityn suite:
=3D sanityn test 73: getxattr should not cause xattr lock cancellation =3D

I'm running stock lustre 2.14.0 on Ubuntu 18.04 with Linux Kernel 5.4.0.  I=
 have six nodes total for the test: two clients, two mds, two oss.  The tes=
t is running from one of the clients.

The error I get is:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
getfattr: Removing leading '/' from absolute path names
# file: mnt/lustre/f73.sanityn
user.attr1=3D"value1"

ELLIS: expected 2, but got 5
sanityn test_73: @@@@@@ FAIL: not cached in /mnt/lustre
 Trace dump:
 =3D /usr/lib/lustre/tests/test-framework.sh:6273:error()
 =3D /usr/lib/lustre/tests/sanityn.sh:3557:test_73()
 =3D /usr/lib/lustre/tests/test-framework.sh:6581:run_one()
 =3D /usr/lib/lustre/tests/test-framework.sh:6628:run_one_logged()
 =3D /usr/lib/lustre/tests/test-framework.sh:6455:run_test()
 =3D /usr/lib/lustre/tests/sanityn.sh:3567:main()
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

I've instrumented the code to spit out the expected vs. discovered stat val=
ues.  The failure indicates the file in question wasn't cached, but in fact=
 the inverse is occurring -- it's both cached and hit more often than expec=
ted.

The unadulterated test code follows:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
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
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

The failure occurs on line 3558.

Manually performing these actions validates that indeed the jump is by 5, n=
ot 2:
~# lctl get_param llite.*.stats | grep hits
getxattr_hits             85 samples [reqs]
getxattr_hits             4 samples [reqs]
~# getfattr -n user.attr1 /mnt/lustre/f73.sanityn
getfattr: Removing leading '/' from absolute path names # file: mnt/lustre/=
f73.sanityn user.attr1=3D"value1"
~# lctl get_param llite.*.stats | grep hits
getxattr_hits             90 samples [reqs]
getxattr_hits             4 samples [reqs]

I straced getfattr as run in the test and found it issues the following:
23262 lstat("/mnt/lustre/f73.sanityn", {st_mode=3DS_IFREG|0644, st_size=3D0=
, ...}) =3D 0
23262 getxattr("/mnt/lustre/f73.sanityn", "user.attr1", NULL, 0) =3D 6
23262 getxattr("/mnt/lustre/f73.sanityn", "user.attr1", "value1", 256) =3D =
6

I built a small C program to replicate just the above without all of the ot=
her fluff in getfattr, and I see 1 xattr cache hit occurring for the lstat,=
 and two xattr cache hits occurring for each call of getxattr.  So it repli=
cates the 5 xattr cache hits.  It is notable that if one does NOT specify "=
user.attr1" and instead just uses an empty string you only get a single hit=
 on each getxattr.

I have a patch that revises the expected stat values from 2 to 5 and from 4=
 to 10, and while that works in my system I wanted to know:
1. Are these changes expected?  I don't know much about the xattr cache or =
when it's expected to be hit, but hitting twice for a single getxattr seeme=
d high.
2. Is there any location online where I can look at release testing results=
 for these unit tests?  I wanted to see if I was alone in hitting this many=
 times, but couldn't locate such a repository of historical test results.

Thanks for any and all help!

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Whamcloud







--_000_MN2PR21MB1439B848E85A1275B8711B43BEB99MN2PR21MB1439namp_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
span.EmailStyle18
	{mso-style-type:personal-reply;
	font-family:"Calibri",sans-serif;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-size:10.0pt;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.0in 1.0in 1.0in;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"EN-US" link=3D"blue" vlink=3D"purple" style=3D"word-wrap:brea=
k-word">
<div class=3D"WordSection1">
<p class=3D"MsoNormal">Hi Andreas,<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Yea &#8211; I noticed that.&nbsp; What makes it even=
 funnier is that it makes allocation calls in statically defined chunk size=
s, so it&#8217;s not even like it&#8217;s exactly the right size in truth.&=
nbsp; If you look at my follow-up email you&#8217;ll see that I RC&#8217;d
 this to auditd mechanics in the kernel, which was enabled on my system.<o:=
p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">I&#8217;m going to open a bug and submit a patch for=
 the test to be more forgiving for test systems that have auditd enabled ne=
xt week.&nbsp; In short, it will assert that it saw at minimum two getxattr=
 hits, rather than exactly two getxattrs hits.&nbsp;
 That&#8217;s behaved well for me since I revised it locally.&nbsp; Let me =
know if you see any issue with this simple solution.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Best,<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">ellis<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<div>
<div style=3D"border:none;border-top:solid #E1E1E1 1.0pt;padding:3.0pt 0in =
0in 0in">
<p class=3D"MsoNormal"><b>From:</b> Andreas Dilger &lt;adilger@whamcloud.co=
m&gt; <br>
<b>Sent:</b> Friday, October 15, 2021 2:19 AM<br>
<b>To:</b> Ellis Wilson &lt;elliswilson@microsoft.com&gt;<br>
<b>Cc:</b> lustre-devel@lists.lustre.org<br>
<b>Subject:</b> [EXTERNAL] Re: [lustre-devel] xattr stat mismatch in sanity=
n test 73<o:p></o:p></p>
</div>
</div>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Ellis, the getfattr code has a poor &quot;optimizati=
on&quot;, in that it first calls getxattr(buf=3DNULL, size=3D0) to have the=
 kernel report the xattr size to allocate a buffer of exactly the right siz=
e. &nbsp;However, IMHO while this avoids a &quot;too large&quot;
 allocation (maybe a few bytes vs. 64KB), it is inefficient by doubling the=
 number of syscalls into the filesystem.&nbsp;
<o:p></o:p></p>
<div>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
</div>
<div>
<p class=3D"MsoNormal">The other getxattr cache hit during lstat() is likel=
y because of the kernel accessing an selinux/security xattr.<o:p></o:p></p>
<div>
<p class=3D"MsoNormal"><br>
<br>
<o:p></o:p></p>
<blockquote style=3D"margin-top:5.0pt;margin-bottom:5.0pt">
<div>
<p class=3D"MsoNormal">On Oct 8, 2021, at 07:04, Ellis Wilson via lustre-de=
vel &lt;<a href=3D"mailto:lustre-devel@lists.lustre.org">lustre-devel@lists=
.lustre.org</a>&gt; wrote:<o:p></o:p></p>
</div>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<div>
<div>
<p class=3D"MsoNormal">Hi all,<br>
<br>
I'm trying to get to the bottom of a failure I'm seeing while running the l=
ustre unit tests, specifically here for this test in the sanityn suite:<br>
=3D sanityn test 73: getxattr should not cause xattr lock cancellation =3D<=
br>
<br>
I'm running stock lustre 2.14.0 on Ubuntu 18.04 with Linux Kernel 5.4.0. &n=
bsp;I have six nodes total for the test: two clients, two mds, two oss. &nb=
sp;The test is running from one of the clients.<br>
<br>
The error I get is:<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
getfattr: Removing leading '/' from absolute path names<br>
# file: mnt/lustre/f73.sanityn<br>
user.attr1=3D&quot;value1&quot;<br>
<br>
ELLIS: expected 2, but got 5<br>
sanityn test_73: @@@@@@ FAIL: not cached in /mnt/lustre <br>
&nbsp;Trace dump:<br>
&nbsp;=3D /usr/lib/lustre/tests/test-framework.sh:6273:error()<br>
&nbsp;=3D /usr/lib/lustre/tests/sanityn.sh:3557:test_73()<br>
&nbsp;=3D /usr/lib/lustre/tests/test-framework.sh:6581:run_one()<br>
&nbsp;=3D /usr/lib/lustre/tests/test-framework.sh:6628:run_one_logged()<br>
&nbsp;=3D /usr/lib/lustre/tests/test-framework.sh:6455:run_test()<br>
&nbsp;=3D /usr/lib/lustre/tests/sanityn.sh:3567:main()<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
<br>
I've instrumented the code to spit out the expected vs. discovered stat val=
ues. &nbsp;The failure indicates the file in question wasn't cached, but in=
 fact the inverse is occurring -- it's both cached and hit more often than =
expected.<br>
<br>
The unadulterated test code follows:<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
3549 &nbsp;&nbsp;&nbsp;&nbsp;touch $DIR1/$tfile<br>
3550 &nbsp;&nbsp;&nbsp;&nbsp;setfattr -n user.attr1 -v value1 $DIR1/$tfile =
||<br>
3551 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;error &quot;setfattr1 =
failed&quot;<br>
3552 &nbsp;&nbsp;&nbsp;&nbsp;getfattr -n user.attr1 $DIR2/$tfile || error &=
quot;getfattr1 failed&quot;<br>
3553 &nbsp;&nbsp;&nbsp;&nbsp;getfattr -n user.attr1 $DIR1/$tfile || error &=
quot;getfattr2 failed&quot;<br>
3554 &nbsp;&nbsp;&nbsp;&nbsp;clear_stats llite.*.stats<br>
3555 &nbsp;&nbsp;&nbsp;&nbsp;# PR lock should be cached by now on both clie=
nts<br>
3556 &nbsp;&nbsp;&nbsp;&nbsp;getfattr -n user.attr1 $DIR1/$tfile || error &=
quot;getfattr3 failed&quot;<br>
3557 &nbsp;&nbsp;&nbsp;&nbsp;# 2 hits for getfattr(0)+getfattr(size)<br>
3558 &nbsp;&nbsp;&nbsp;&nbsp;[ $(calc_stats llite.*.stats getxattr_hits) -e=
q 2 ] ||<br>
3559 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;error &quot;not cached=
 in $DIR1&quot;<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
<br>
The failure occurs on line 3558.<br>
<br>
Manually performing these actions validates that indeed the jump is by 5, n=
ot 2:<br>
~# lctl get_param llite.*.stats | grep hits<br>
getxattr_hits &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;85 samples [reqs]<br>
getxattr_hits &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;4 samples [reqs]<br>
~# getfattr -n user.attr1 /mnt/lustre/f73.sanityn<br>
getfattr: Removing leading '/' from absolute path names # file: mnt/lustre/=
f73.sanityn user.attr1=3D&quot;value1&quot;<br>
~# lctl get_param llite.*.stats | grep hits<br>
getxattr_hits &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;90 samples [reqs]<br>
getxattr_hits &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;4 samples [reqs]<br>
<br>
I straced getfattr as run in the test and found it issues the following:<br=
>
23262 lstat(&quot;/mnt/lustre/f73.sanityn&quot;, {st_mode=3DS_IFREG|0644, s=
t_size=3D0, ...}) =3D 0<br>
23262 getxattr(&quot;/mnt/lustre/f73.sanityn&quot;, &quot;user.attr1&quot;,=
 NULL, 0) =3D 6<br>
23262 getxattr(&quot;/mnt/lustre/f73.sanityn&quot;, &quot;user.attr1&quot;,=
 &quot;value1&quot;, 256) =3D 6<br>
<br>
I built a small C program to replicate just the above without all of the ot=
her fluff in getfattr, and I see 1 xattr cache hit occurring for the lstat,=
 and two xattr cache hits occurring for each call of getxattr. &nbsp;So it =
replicates the 5 xattr cache hits. &nbsp;It
 is notable that if one does NOT specify &quot;user.attr1&quot; and instead=
 just uses an empty string you only get a single hit on each getxattr.<br>
<br>
I have a patch that revises the expected stat values from 2 to 5 and from 4=
 to 10, and while that works in my system I wanted to know:<br>
1. Are these changes expected? &nbsp;I don't know much about the xattr cach=
e or when it's expected to be hit, but hitting twice for a single getxattr =
seemed high.<br>
2. Is there any location online where I can look at release testing results=
 for these unit tests? &nbsp;I wanted to see if I was alone in hitting this=
 many times, but couldn't locate such a repository of historical test resul=
ts.<br>
<br>
Thanks for any and all help!<o:p></o:p></p>
</div>
</div>
</blockquote>
</div>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<div>
<div>
<div>
<div>
<div>
<div>
<div>
<div>
<p class=3D"MsoNormal"><span style=3D"color:black">Cheers, Andreas<o:p></o:=
p></span></p>
</div>
<div>
<p class=3D"MsoNormal"><span style=3D"color:black">--<o:p></o:p></span></p>
</div>
<div>
<p class=3D"MsoNormal"><span style=3D"color:black">Andreas Dilger<o:p></o:p=
></span></p>
</div>
<div>
<p class=3D"MsoNormal"><span style=3D"color:black">Lustre&nbsp;Principal Ar=
chitect<o:p></o:p></span></p>
</div>
<div>
<p class=3D"MsoNormal"><span style=3D"color:black">Whamcloud<o:p></o:p></sp=
an></p>
</div>
<div>
<p class=3D"MsoNormal"><span style=3D"color:black"><o:p>&nbsp;</o:p></span>=
</p>
</div>
<div>
<p class=3D"MsoNormal"><span style=3D"color:black"><o:p>&nbsp;</o:p></span>=
</p>
</div>
<div>
<p class=3D"MsoNormal"><span style=3D"color:black"><o:p>&nbsp;</o:p></span>=
</p>
</div>
</div>
</div>
</div>
</div>
</div>
<p class=3D"MsoNormal"><span style=3D"color:black"><o:p>&nbsp;</o:p></span>=
</p>
</div>
<p class=3D"MsoNormal" style=3D"margin-bottom:12.0pt"><o:p>&nbsp;</o:p></p>
</div>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
</div>
</div>
</body>
</html>

--_000_MN2PR21MB1439B848E85A1275B8711B43BEB99MN2PR21MB1439namp_--

--===============7299337125331426874==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7299337125331426874==--
