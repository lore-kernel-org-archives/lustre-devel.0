Return-Path: <SRS0=JELb=GD=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63F0AC433E0
	for <lustre-devel@archiver.kernel.org>; Thu, 31 Dec 2020 00:52:27 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F2C6F21973
	for <lustre-devel@archiver.kernel.org>; Thu, 31 Dec 2020 00:52:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2C6F21973
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=whamcloud.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6C53E21F465;
	Wed, 30 Dec 2020 16:52:26 -0800 (PST)
Received: from NAM10-MW2-obe.outbound.protection.outlook.com
 (mail-mw2nam10on2052.outbound.protection.outlook.com [40.107.94.52])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9F14E21F255
 for <lustre-devel@lists.lustre.org>; Wed, 30 Dec 2020 16:52:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=XW3lAzEFKkCZMJ1yWOeQiTz8C8ZX3WKFV+qRgAmtYS2uu4HuhtTj8hSC+sbzDMz8rWu5v2mZDOpxN3DuXpHXQzVu8u2Jyq+J+jFzw6hlzgF72v0ksTqTBDpS20cSHRbs7mMcn9TFqJUnFQBceV99gSEz6RUaBLevVYT9W9BpMKCFdvuiVjeaVtnx1lZ9c9Zuq29DdQEZRbT7jMs85fcKU7m9tTSvSmRyJT2KHbxWS6VDcaY+f+vBbJD8f/7MPXRyCmB0bvdddLGHdF2AoDvkB6yLvgEZ3vISXlGZ6zGNBYhSFy7UsVthhHKu2kw3I7pM7zVNoN0tmaNuF2K5ZmHUow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Y76m+K0LP/Yfl/+XCPcnkler9jNci4GJmMEpF3hreAI=;
 b=TWsHYtp1LGXFYXgWJ+Crn2QiQTG72Uwhr0Z3bFMnvWxrNiB8Nmbjz7CFCTpGzWjqo2HnNNIgLJnEwMaEm0PrDPmle9VOWrqiiDwi8aSLBMQB8K6GGENQtmMmEgLjGgPAs2aHQgnVrT14F49v25/FIdenhJ9JZcdN5vjK4GFyBgsnaBfQN1r9bIbiXIoHa1CrQFj0aNctijLivG7oKmM6+q73KuSVIiuoNqIDbcAqYZft37CsCDFTtseZEQCsUOzz72UidryZ7jU01TJrtpp4Aw93cCXdcOE20UYaKVKdTrzMFzm6Yz92digsHRjjjBuGVySWV9Pezh8U7p6UmuSwCw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Y76m+K0LP/Yfl/+XCPcnkler9jNci4GJmMEpF3hreAI=;
 b=t+kL07KgGukFTdaa63DZnePY5qemcw3suGAjdfIW13cosOvAqTQGTR0/nJxMxFVN9I1TmiADSw0cnXAHRRamqGaIfSFqr8Q7jCIrA2bNPfiG1FcJnO8r1FjQELoRVB+KzGNRtqvJxRR9q1TpIL25bTS6q8GE3ZhFTV4ilYrq+vE=
Received: from MN2PR19MB3662.namprd19.prod.outlook.com (2603:10b6:208:193::28)
 by MN2PR19MB3744.namprd19.prod.outlook.com (2603:10b6:208:1e9::10)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.3700.27; Thu, 31 Dec
 2020 00:52:21 +0000
Received: from MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::944:8292:35d7:98ca]) by MN2PR19MB3662.namprd19.prod.outlook.com
 ([fe80::944:8292:35d7:98ca%7]) with mapi id 15.20.3721.020; Thu, 31 Dec 2020
 00:52:21 +0000
From: Andreas Dilger <adilger@whamcloud.com>
To: Sudheendra Sampath <sudheendra.sampath@gmail.com>
Thread-Topic: [lustre-devel] mdc_resource_inode_free()
Thread-Index: AQHW2KC5GkxAoAA6BEm1jDRcye9unqoQbSEA
Date: Thu, 31 Dec 2020 00:52:21 +0000
Message-ID: <5481DEA0-3A35-44AC-81E4-F8684A3AF588@whamcloud.com>
References: <CABnqofyiOSkBVO4q1BfpMtN0AR3EO2gEsHruYdwYe+csEQShzw@mail.gmail.com>
In-Reply-To: <CABnqofyiOSkBVO4q1BfpMtN0AR3EO2gEsHruYdwYe+csEQShzw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: gmail.com; dkim=none (message not signed)
 header.d=none;gmail.com; dmarc=none action=none header.from=whamcloud.com;
x-originating-ip: [70.77.221.9]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 60dd0586-1c9d-43ce-c496-08d8ad2654b9
x-ms-traffictypediagnostic: MN2PR19MB3744:
x-microsoft-antispam-prvs: <MN2PR19MB374416F1E4FD57AE31EC3A83A7D60@MN2PR19MB3744.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: 5B1YgFbtBfiJtzwRGVcbI5o/enEk6tifwjeGNPJvqTLtQgAqBhRiiZvBXVXDYD7rKLUSman8G4G1h/5b+JR+Ik04FSk1CVFjigOd5Ua2Fou4HxUugSqRFShK7YZQQ/P+Ew3+i/mhpUnXLA0rZXfLKSpUFCjT1cyoOIkHjZWbO5RYFSU52pGFgq4cg/CMG2J/u99rmfnP1DQv5d9XR3QXnr8GfxmpUlaNt6QAhIZbAfai+LFmjevsC3R0AaVjYAQKJAbHO3FDK0COUgMWpCs/PM5jegSlPQQP8RFXV5BvaCjFr80rgKjTuI6Ljq4/HwmcscEjICmW+xTd6XUiI4NodncEJd4pWGfAs1DspH3GFVww8keN2I5A8dueKtu1M0xYEdnGCxfddx/oHv+zvvpH9qA5pxG8iLHcS1Lqm//C8mmZ4jafX2Bznt5wmJBp32uiGGspKNmI1ejY6CJFxacLCYmdXRRjaMp/llOwyMv+PxY=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MN2PR19MB3662.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(376002)(136003)(346002)(39850400004)(366004)(396003)(26005)(66946007)(6506007)(91956017)(76116006)(66446008)(66476007)(2906002)(5660300002)(36756003)(64756008)(8676002)(33656002)(2616005)(86362001)(66556008)(6512007)(6486002)(6916009)(71200400001)(83380400001)(186003)(4326008)(53546011)(316002)(478600001)(8936002)(13693001)(45980500001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata: =?us-ascii?Q?mbbEpXgYdcdnhZ5HSMJh2CjvCpYBfDYrKGAKdO9MXC08+TBWp+saDXjdQAJk?=
 =?us-ascii?Q?EYIFe49A7lnDFgYS4JpnbFj/3bkLT7HRlrWpgYgYDeGABaHItCUL7EB8IWrZ?=
 =?us-ascii?Q?mrx0Ou5VCuSU9Ux+kyUaqAQn/qwHTlJ3AQIJ/hqh0Ju3rvnNvj8N0l7I5KBx?=
 =?us-ascii?Q?hyqjlWVSSYke5CcsXGaKb1srfwlXoJicY2z+EOXGyzugnU/f+LNel6tydNb8?=
 =?us-ascii?Q?wX9pvLGq3tmApWWR1yRD9wFd+zQmZ3Vbr4gCqvDrsnA4YBU/oEEEtnxNQOq5?=
 =?us-ascii?Q?Sng9RqxW3fVEAzi1lTwCIn6GsONxcuhS6xYIGD8eagWpqoNfJS/c/dIzSvDH?=
 =?us-ascii?Q?fv6a4C9XB4KyE9hyBucq4hqZIJ3jkwPp3ujAvZwNwfhOxqJuqJJgai5XIkDK?=
 =?us-ascii?Q?NklCJAUGy7yoV3z5Ww6AKPLuKvbDfV1Tr/ZTld1vEh4ry9JfiX+1bcMAhdZB?=
 =?us-ascii?Q?wy9aaHSs4Kpu8SS05Qu9/xtLHWpyBR8Op5ypHs2ZEDixxE5jQ7rp7Cfix0vf?=
 =?us-ascii?Q?ugEj/2Z8ra5azIpHMgRubSbyHjqLwUHaWg6qTCjp9AE4/ASSgm3XkHMEDTpS?=
 =?us-ascii?Q?P/7FOAAUDhvvv3PwBoU4EmR0LK2+43bYvL0XHmykKATGUUg9Jp9ebIeaQ+IV?=
 =?us-ascii?Q?TnQNFnY894zBc11OcF3UUklhqwVXQwDTf36FN7lOLHJGcKVxMAUIDDi6/U5X?=
 =?us-ascii?Q?tsYFPfAYCcNrCQcERowggTpBpJ7xEex8vXcpwJE19qADjJTIE9NsEFqLvtJU?=
 =?us-ascii?Q?CnoSN3rewjtVTGZwr8bFRTNW6U2s8wZPt+icczQ5X49TegCC3/IeTfHpG5/e?=
 =?us-ascii?Q?7vX52h1c3udOSTg0c0azDZ7fT82v4aziG9NJIb8ygV1NLGOSYvEEm8cL/BZ8?=
 =?us-ascii?Q?rMy9+L4u9en3J8e9e9AZw9rRcCOB8w6OJKefnmEjsHIApx/741pKIMOvKnyJ?=
 =?us-ascii?Q?ZvfIMeMPBbTjlCh7nSK0UWtThXhRe0O9eU7/hHiiIImWAaKNl9lPlGjxU0bE?=
 =?us-ascii?Q?81xh?=
x-ms-exchange-transport-forked: True
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MN2PR19MB3662.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 60dd0586-1c9d-43ce-c496-08d8ad2654b9
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Dec 2020 00:52:21.2279 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: HvtKGn4lPv8KIQ2SSUGBzrvArCq9kQbu82+/HKl2AavmuySSLPXwERaEaCEbmkzJ
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR19MB3744
Subject: Re: [lustre-devel] mdc_resource_inode_free()
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============0754737080244362151=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============0754737080244362151==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_5481DEA03A3544AC81E4F8684A3AF588whamcloudcom_"

--_000_5481DEA03A3544AC81E4F8684A3AF588whamcloudcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Dec 22, 2020, at 13:25, Sudheendra Sampath <sudheendra.sampath@gmail.com=
<mailto:sudheendra.sampath@gmail.com>> wrote:

Hi,

I was trying to understand more about LDLM, specifically Lock Value Block (=
LVB's) and stumbled upon the following code block :

static int mdc_resource_inode_free(struct ldlm_resource *res)
{
        if (res->lr_lvb_inode)
                res->lr_lvb_inode =3D NULL;

        return 0;
}

Shouldn't the pointer (lr_lvb_inode) be freed before assigning it to NULL ?

Just curious to know.

The "lr_lvb_inode" pointer is a pointer to the VFS inode that is referencin=
g a lock/resource:

int mdc_set_lock_data(struct obd_export *exp, const struct lustre_handle *l=
ockh,
                      void *data, __u64 *bits)
{
        struct inode *new_inode =3D data;
        :
        lock->l_resource->lr_lvb_inode =3D new_inode;
}

The inode is allocated/freed separately by the VFS.  The lr_lvb_inode point=
er is used to quickly find the VFS inode from a DLM resource, but does not =
take a reference on the inode itself.  Otherwise, the inode would always ha=
ve an elevated reference count and would never be freed by the VFS.

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud







--_000_5481DEA03A3544AC81E4F8684A3AF588whamcloudcom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <330C1C306A5DEC40886EFFF9BCB32C62@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
On Dec 22, 2020, at 13:25, Sudheendra Sampath &lt;<a href=3D"mailto:sudheen=
dra.sampath@gmail.com" class=3D"">sudheendra.sampath@gmail.com</a>&gt; wrot=
e:<br class=3D"">
<div>
<blockquote type=3D"cite" class=3D""><br class=3D"Apple-interchange-newline=
">
<div class=3D"">
<div dir=3D"ltr" class=3D"">Hi,
<div class=3D""><br class=3D"">
</div>
<div class=3D"">I was trying to understand more about LDLM, specifically Lo=
ck Value Block (LVB's) and stumbled upon the following code block :</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">static int mdc_resource_inode_free(struct ldlm_resource *re=
s)<br class=3D"">
{<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; if (res-&gt;lr_lvb_inode)<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; res-&gt;lr_lvb_inod=
e =3D NULL;<br class=3D"">
<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; return 0;<br class=3D"">
}<br class=3D"">
<div class=3D""><br class=3D"">
</div>
<div class=3D"">Shouldn't the pointer (lr_lvb_inode) be freed before assign=
ing it to NULL ?&nbsp;&nbsp;</div>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">Just curious to know.</div>
</div>
</div>
</div>
</blockquote>
<br class=3D"">
</div>
<div>The &quot;lr_lvb_inode&quot; pointer is a pointer to the VFS inode tha=
t is referencing a lock/resource:</div>
<div><br class=3D"">
</div>
<div>int&nbsp;mdc_set_lock_data(struct&nbsp;obd_export *exp,&nbsp;const&nbs=
p;struct&nbsp;lustre_handle *lockh,<br class=3D"">
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=
;&nbsp;void&nbsp;*data, __u64 *bits)<br class=3D"">
{</div>
<div>&nbsp; &nbsp; &nbsp; &nbsp;&nbsp;struct&nbsp;inode *new_inode =3D data=
;<br class=3D"">
</div>
<div>&nbsp; &nbsp; &nbsp; &nbsp; :</div>
<div>&nbsp; &nbsp; &nbsp; &nbsp;&nbsp;lock-&gt;l_resource-&gt;lr_lvb_inode =
=3D new_inode;</div>
<div>}</div>
<div><br class=3D"">
</div>
<div>The inode is allocated/freed separately by the VFS. &nbsp;The lr_lvb_i=
node pointer is used to quickly find the VFS inode from a DLM resource, but=
 does not take a reference on the inode itself. &nbsp;Otherwise, the inode =
would always have an elevated reference count
 and would never be freed by the VFS.</div>
<div><br class=3D"">
</div>
<div class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div dir=3D"auto" style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); =
letter-spacing: normal; text-align: start; text-indent: 0px; text-transform=
: none; white-space: normal; word-spacing: 0px; -webkit-text-stroke-width: =
0px; text-decoration: none; word-wrap: break-word; -webkit-nbsp-mode: space=
; line-break: after-white-space;" class=3D"">
<div>Cheers, Andreas</div>
<div>--</div>
<div>Andreas Dilger</div>
<div>Principal Lustre Architect</div>
<div>Whamcloud</div>
<div><br class=3D"">
</div>
<div><br class=3D"">
</div>
<div><br class=3D"">
</div>
</div>
</div>
</div>
</div>
</div>
<br class=3D"Apple-interchange-newline">
<br class=3D"Apple-interchange-newline">
</div>
<br class=3D"">
</body>
</html>

--_000_5481DEA03A3544AC81E4F8684A3AF588whamcloudcom_--

--===============0754737080244362151==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0754737080244362151==--
