Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DA1DDC433EF
	for <lustre-devel@archiver.kernel.org>; Tue, 28 Dec 2021 01:58:57 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 20F293A696B;
	Mon, 27 Dec 2021 17:58:55 -0800 (PST)
Received: from NAM04-MW2-obe.outbound.protection.outlook.com
 (mail-mw2nam08on2079.outbound.protection.outlook.com [40.107.101.79])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 942EC21F7BB
 for <lustre-devel@lists.lustre.org>; Mon, 27 Dec 2021 17:58:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=eoXvN/SwZTjdvMDp7ED/OgXZxH1MhyKnk4xG4aD26uRO+20vH4NVBioPWbjLJJtjebOjXNmMKT2FzTH5bskhzUlNFAluWKzudcwieLwZnE2lty20IeHkDWcATTqfOc4bXlugebsw5+cs3ezvSmoL+vsHSapuoZtf1+Hka+RSfG7Rkdi6jy4wUvMIlOCnIF3r6YCquKkVlWd1tkLZTQLKkUqQeX73q5ZRWx28mJJbQ1KsYmnc7NBCs6Tnm3dv3Dk1e1Su2G5i9iLYS1BGZ0+w17NDDjUY3+VI/8qjF1Ne7+pP5RSCEd6KQmd5o9BfcfiEoQw2zY4o8nqSFcO6fNGH9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=49l3BOWHHNV3OCCx2xnTeu9+4KdhK/AKF7CpzgSJ5+k=;
 b=WUcAGZD4IVVzIj36XddX8TvK2h7MMkNHB1m6sGauHfepqOZ1BdfXhEKCd2yCaS0AXKj/n9FcDrlYVYINPLWwvWZc2Nry5X0tK1ROH110IM9JlYbRWquoR7xtrAJFwpGM42eBxcVn0M+glsF8PY6BRa56uAddkqUBNJOTcUj1zgcaIuwQQ0eTvFuZC690r1rKy0q0ajzGTcSSTbb/ZDEENhwn402p2waogS+xthOcTpOdEkVuMwUz9so3fHF463LoVUTanrdyzRdrTelCa652N0t/b2rCK44KYWG6yFEXGeEuettV+uaGIWoIGIeJA05m58y/PVaJbDxw4HptK9wZwQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=49l3BOWHHNV3OCCx2xnTeu9+4KdhK/AKF7CpzgSJ5+k=;
 b=OM1gQWUbDovrLDQIMZXy1riGYaXULgbnefGr2Zf7BH7WtBEQ0dKPLJRConF9SjlM/JPPddSHSEX0DW+puhNlEVU0+GWfbmmHINYMKsk2/4vmFMfZgqhAzvtkLW8SM5QrgC+5GZhM/En/poKPZIMI0tudkxQgQaOB5g4H3PYGJas=
Received: from BN6PR19MB0146.namprd19.prod.outlook.com (2603:10b6:405:6b::23)
 by BN6PR19MB3169.namprd19.prod.outlook.com (2603:10b6:405:7d::21)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4823.22; Tue, 28 Dec
 2021 01:58:52 +0000
Received: from BN6PR19MB0146.namprd19.prod.outlook.com
 ([fe80::6c29:fb73:8830:3480]) by BN6PR19MB0146.namprd19.prod.outlook.com
 ([fe80::6c29:fb73:8830:3480%7]) with mapi id 15.20.4823.023; Tue, 28 Dec 2021
 01:58:51 +0000
To: Xinliang Liu <xinliang.liu@linaro.org>
Thread-Topic: Lustre Arm stuff status and work plan
Thread-Index: AQHX8lZb6p5/653Ee0+vr6HXAC45zaw6ro4AgAUOLoCABkz3AIAAfR0AgACvz4CAAAGfgA==
Date: Tue, 28 Dec 2021 01:58:51 +0000
Message-ID: <023CD146-E2BA-4B03-9459-C480E51EBE7E@whamcloud.com>
References: <CAKoKPby+hn5+py-f11c31Po241871un0v=SQM+Cc6_hzvxW8uA@mail.gmail.com>
 <CAKoKPbxTcSxGzASKyVhiv_7W3OY6x3DRtkcTu8hzvLM+4-PzZw@mail.gmail.com>
 <6C592E3F-0437-4776-BB29-C5EE489C5FAE@whamcloud.com>
 <CAKoKPbxmvn7GVc6wsYrLP_HD8SpNMVFfSFdiZMo-5ZXqS-HSdg@mail.gmail.com>
 <7AAC4FDA-AC84-4E73-83AB-130B6BD3AE1B@whamcloud.com>
 <CAKoKPbxQymhN93F5oM_TxK6y0kk5_bv3p62FncUz6Ri_0jmABw@mail.gmail.com>
In-Reply-To: <CAKoKPbxQymhN93F5oM_TxK6y0kk5_bv3p62FncUz6Ri_0jmABw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 170eb990-ecff-47d6-8832-08d9c9a598b7
x-ms-traffictypediagnostic: BN6PR19MB3169:EE_
x-microsoft-antispam-prvs: <BN6PR19MB3169CB5EBFD5A8FE6F436203AC439@BN6PR19MB3169.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: 3JnZPLSdLKokc/bYvOQ2IASv2io2dTlRAY+qRhJV12aWUsW42FfqS4g+g3oTwxA7JnZ9NQZVOpdOXSE4HBq45tnY2j+rhPYIfuNpFFdDtELb99PB8sTIdmvVv8vZK/VYA/rd9FZ2f4xsAUKTZH7jZwp+l18+MLPVWmca6VHVwuuogdOr4tHJVyLT5XesyZKqDMPiFEqHlXOIurnQfelLnVtM6+nkgZNmEEhvCQcfOEHrqW0mJRv68zGHErRU0MRsWlR92tuy3da3TPxa5/3tAToWQ24JqkvftlchXoGoo3iuoAml0ws83Zq/kMGxbiiJQj/5HmIbuzx+wzI7ntjNCDXJwivOJkRodiTOlB6Z/I7geeIO1Etqt+F6jXIBveauewtf8xOIVPRaTUSLJgW/yuWQhx1gbg6+MYPSEeVIecllvtISB+yeC/6YmyGvQklY2IKwa+1+beH31dFIC6uRTcnMvnyS6XZVemaxen89rtbvbTNDWech2m926/Ulu5eYm4APMMI+xnP7YF/KoPjItScLPy11ItUsNc2RDpKH2cPYyLN/9lo9LHbyjZJbHhtkNhiVPaA0wv9hfsf+EnEEhcXXggWtOrQYsPYPE5HnhVhfPUlRkFNZHYJ8KBtRkUtCzr6iBmRu7Co/k4RBm01Bkyw3V6wRhLx3TIHQ77ay3tVwrSu1i39ti7KYgr3X5RWUIagmtQeOLy3GXSZaaRtWsfx8BOad+Jc1hHQngoXACKnFVW19pGkOHSXtQ64GDlS+lIu6w5JqPxbK5aw5+QRYpA==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:BN6PR19MB0146.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(366004)(2906002)(38100700002)(2616005)(5660300002)(36756003)(66946007)(122000001)(53546011)(6506007)(6486002)(26005)(6916009)(186003)(4326008)(76116006)(38070700005)(4744005)(71200400001)(316002)(33656002)(8676002)(86362001)(66476007)(83380400001)(8936002)(6512007)(64756008)(508600001)(54906003)(66446008)(66556008)(13693001)(45980500001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?vwjJEC9KzyLf+pNSoIz3OI9vy5JilDiuNQO/lWfEaEYo8XDswAdrxHAQTDbf?=
 =?us-ascii?Q?qluQsrAu2wog/t8VStGObh5A/hTKNfRTXuC7OpUyd8mltyvxk1XC7dRt9I3a?=
 =?us-ascii?Q?s3KfriZWxbrDC80tFP0FhtD3hwMexEskPXfy06FEI1T2JzSBKYnWdNUbonDd?=
 =?us-ascii?Q?ze4QQ9ZN1SobiQ/WfbHgC6+D1UYGnY66Tgm4F08Isi91Y3ofufTKFbnm6NWM?=
 =?us-ascii?Q?lyr1+CeyBh36j/SpRKkYYp9Jf6wBTG4xdifNgWw4B+mHlE1rJP1QYqQ6c4Sy?=
 =?us-ascii?Q?8dRPYe1bryJm2KgM5gHQHeBh691T/meTl/VVatGfhrQ6pAjWG/ex52hsY3N2?=
 =?us-ascii?Q?b0vWURreE0TW7uMcWjZGCtPg7WbGNbWLEa0JD2poPH1IMUiaN0SCbKclOOFk?=
 =?us-ascii?Q?Ofsvzg70BdC0GtNuwWC6itJnd6ZqcDDvM8uUfTSGUqdl0YgRlr5ObLaxsVSs?=
 =?us-ascii?Q?Gv9DOygrxSK/0GL5SYBWiimgxnj3Xkf0q5i96w/Qo7R4NRohEVH3tPJbJWrm?=
 =?us-ascii?Q?40t7jhnej8ZdI0hPLf6JpzhE29kkSfdOszwkanx4pq4u73lFJzKK+e8e3ATJ?=
 =?us-ascii?Q?OPoFl8WdfvCmER+yWfjqIIPZMYtGzJfkMWd0QBXt62QGDZKBrgY1PXS8u89C?=
 =?us-ascii?Q?BQojE15fMGGXxkeoC4RF4n2mdYTgTMcZQ/FVEI3pBTLhlQeV/GTc8AqaMRpc?=
 =?us-ascii?Q?9robyhQYo0F5hDh3schUC5lLZ3CC20qyM1VtW8R75+Ry+ChcTBWmNWv96Kss?=
 =?us-ascii?Q?FZ2pWexcz2Ixfnu+BCexh33aKNv7liwY+a/xIXQAaLuplj3YccQTPTJHS6Tz?=
 =?us-ascii?Q?ROcSQEr4UdOkBarHCPU4J+3AVXT0sNi502fyuPlG9rfkHz9p+Mt0cmJuiSdS?=
 =?us-ascii?Q?7kWvzkzV9X8MlzgsbE1iu+pe0Y+yDdH9dvQlgUY/6SRJm5rA+W/Sc9ZzjyXy?=
 =?us-ascii?Q?IHznDF0JqkcCc9Nh9RWqSlFluy/WsG6hxHIsAcM5l385ypoO0uBdY/cQLD7q?=
 =?us-ascii?Q?t6GD3NeDyX6j58jx0WSEUKoI0by5TMYZMrBSBqrxwDWPjp2jd5npDC+Szwyl?=
 =?us-ascii?Q?wQz85J7437l/X94Qwe5uXnKQiZC2Le6/MirOzAC17K22eUQh3DlwqiHqdych?=
 =?us-ascii?Q?GE06OfwBvPF0+jP+u3exdN/N/yhSJWgdYQz6MciZ7up/+R7xsGka1uJPZm7x?=
 =?us-ascii?Q?P4xSyC7mbWnY+BMmIgdwpz/0pnz5ZE2FdNs2GzU/9KxTiMxmYX5bFQ4JltXs?=
 =?us-ascii?Q?a/x0RBBqNHWx4IhIlzxkD2jsUqeDwgaaVa91y/aKmh2hOP+OiQbXLrJb8sia?=
 =?us-ascii?Q?BCVwo3OEOppwE1ZhFc9gLiN569utVY+sd99G9kk2K6+ap7AOxpFSUNtUI7ro?=
 =?us-ascii?Q?ZUYQdTBEkIAhdHAAbLTMg4X0BvWkkMdp6AphCBZFaZCER0IprWeudEazgAdl?=
 =?us-ascii?Q?1prCcCsR647gQfNarHOgjsttXBDEl8Eah9YC5/+m5hIla41AJSz4h7NFcfTP?=
 =?us-ascii?Q?IheIVnzPVgjPY9AvL78QNMihTYCXqhhZgGoVR1Xt1jb9HIOhNstd/O91iGvo?=
 =?us-ascii?Q?Ikfam5OekA9r8hRYQxM=3D?=
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: BN6PR19MB0146.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 170eb990-ecff-47d6-8832-08d9c9a598b7
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Dec 2021 01:58:51.6243 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Fz47hcVARaPBdkg77HBpzmOowC1aQxM+kRue2JZsR/28RsdSVmU9O36c5tcWJXG+
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR19MB3169
Subject: Re: [lustre-devel] Lustre Arm stuff status and work plan
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
From: Oleg Drokin via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Oleg Drokin <green@whamcloud.com>
Cc: Jian Yu <jiyu@whamcloud.com>, Li Xi <lixi@ddn.com>,
 "cloud-dev-request@op-lists.linaro.org"
 <cloud-dev-request@op-lists.linaro.org>,
 Xinliang Liu via lustre-devel <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============1665507722653878189=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============1665507722653878189==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_023CD146E2BA4B039459C480E51EBE7Ewhamcloudcom_"

--_000_023CD146E2BA4B039459C480E51EBE7Ewhamcloudcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable



On Dec 27, 2021, at 8:53 PM, Xinliang Liu <xinliang.liu@linaro.org<mailto:x=
inliang.liu@linaro.org>> wrote:

Maloo is just one place to link to to actually let people see the results, =
but you can link to external resources too
like e.g. gatekeeper janitor helper does or assuming the information is sma=
ll enough it could be entirely contained
in the comment (like say for a build failure)

Ok, understand now. Is there any other reference external CI that posts res=
ults to Lustre gerrit now?

Currently there are:
- checkpatch and Misc code checks (smach) that post their results as 100% c=
omment only. they share codebase pretty much
- the Janitor (also started with above codebase but got changed and extende=
d a lot)

There was external interest in the past to post results to gerrit but it ne=
ver materialized in the end

--_000_023CD146E2BA4B039459C480E51EBE7Ewhamcloudcom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <0B69BC7EF24F4848A44A4152C87DBBE7@namprd19.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
<br class=3D"">
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">On Dec 27, 2021, at 8:53 PM, Xinliang Liu &lt;<a href=3D"ma=
ilto:xinliang.liu@linaro.org" class=3D"">xinliang.liu@linaro.org</a>&gt; wr=
ote:</div>
<div class=3D"">
<div dir=3D"ltr" class=3D"">
<div class=3D"gmail_quote"><br class=3D"">
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left:1px solid rgb(204,204,204);padding-left:1ex">
Maloo is just one place to link to to actually let people see the results, =
but you can link to external resources too<br class=3D"">
like e.g. gatekeeper janitor helper does or assuming the information is sma=
ll enough it could be entirely contained<br class=3D"">
in the comment (like say for a build failure)<br class=3D"">
</blockquote>
<div class=3D""><br class=3D"">
</div>
<div class=3D"">Ok, understand now. Is there any other reference external C=
I that posts results to Lustre gerrit now?</div>
</div>
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
Currently there are:</div>
<div>- checkpatch and Misc code checks (smach) that post their results as 1=
00% comment only. they share codebase pretty much</div>
<div>- the Janitor (also started with above codebase but got changed and ex=
tended a lot)</div>
<div><br class=3D"">
</div>
<div>There was external interest in the past to post results to gerrit but =
it never materialized in the end</div>
</body>
</html>

--_000_023CD146E2BA4B039459C480E51EBE7Ewhamcloudcom_--

--===============1665507722653878189==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============1665507722653878189==--
