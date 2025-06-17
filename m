Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 841F3C71157
	for <lustre-devel@archiver.kernel.org>; Tue, 17 Jun 2025 08:47:52 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4bM0r432jkz1xQ5;
	Tue, 17 Jun 2025 01:47:48 -0700 (PDT)
Received: from TYVP286CU001.outbound.protection.outlook.com
 (mail-japaneastazolkn19011025.outbound.protection.outlook.com [52.103.43.25])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange ECDHE (secp384r1) server-signature RSA-PSS (2048 bits)
 server-digest SHA256) (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4bM0qp2SBkz1wrF
 for <lustre-devel@lists.lustre.org>; Tue, 17 Jun 2025 01:47:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=lKqGS/jShrB7Ri97JCufELPqepISLbHPm+R0okHA4/vHZc34/niWY3nLW4PliVQ+xPsQT8+UQ9saz2IYdYXyyQAC9ULYVnHWwyVY0VUK5RcDzf+5N+xxn6NxG0aFhr9OIVbk0EMvSdwz+OBTuAb03PAuxz6jEkLXxrwJdh1n/QjVZr3l/ZLFTOOaUsoCRj6KeW4Fp4XPLNC7s/E7AjoZSXM17UtQDTsd2k2ZneNOe+QI9wp0LrNMMnci9bRiLLFwXGugyBpBHqUJlPL4QaUjdxXcXgX+rRxGXIQbzq14YwXRaHbTv4maEMX6KW0hWrXmfvNOWz8dSKow1W3kSIvJNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=TWXWxrB/EypuvlyabWiDwSa5S569QnT3lRNfuy9v5S8=;
 b=UMb/Wo23CfxThjXduRhuoUjHd4wkUi+Djy02nXEDE9yZzfGOU6gMscmF+73lW3Q9HqACsMNgMnkmn9ScW9o6Lu/SeqWKs7Ju0QF5A2KuyXrIYOBFhYNUK5BZrMP8kRlK+MAOjHa+INShR4lgpnhss5+V02wszv1FSBuhVjq3Vcww87lYKgDV8tdHtvUvLVJRqw1BCI8pyrnN+ecYmT/f6RF9gUWJtakiszU+EdJ+AStRl+qYIBwv5rOAaaDOzKYJPGWj3Hf1ZGcpX7EqMMllto+35rQyatmRttPujfqlX7+tYZ5PpfUf+RIqpQTGtAUdxgeUOZAKNrMau3ya7XYOIA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=none; dmarc=none;
 dkim=none; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=outlook.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=TWXWxrB/EypuvlyabWiDwSa5S569QnT3lRNfuy9v5S8=;
 b=UtHcXoRXw0oLO0mjVv/IxEQmBu+s2MkQ7AuGwRv7P3eBVceXYwZ5jtOSB4qObmzIakaIJW4yTDliIemOMZX0zNmUi36JV3EUKUJcmQ2fQm0Cuv7xbKEeTYUTZuxikoyvqwvM92+y3Lg3GBihJv7LNjOExicdywQa4j2rgxOOwudiYnsBp0kIsWgHa+yONNxR8JUZ3W/ffSZWBh1QejBojSKhGXoJsRkFUj1EWgG4iAa3iiM043lUuiIy7+J8fiz1T51r127kip648wPSVGxzqTlY42759caJIca+XnkcS7RHGamesFqsgTs/LG4DG0eY+Its2XoRzWDbhg2217MaWw==
Received: from OS7PR01MB11902.jpnprd01.prod.outlook.com
 (2603:1096:604:23d::12) by TYWPR01MB10146.jpnprd01.prod.outlook.com
 (2603:1096:400:1e6::9) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8835.29; Tue, 17 Jun
 2025 08:47:31 +0000
Received: from OS7PR01MB11902.jpnprd01.prod.outlook.com
 ([fe80::6524:7e27:2cf8:d0d5]) by OS7PR01MB11902.jpnprd01.prod.outlook.com
 ([fe80::6524:7e27:2cf8:d0d5%3]) with mapi id 15.20.8813.024; Tue, 17 Jun 2025
 08:47:31 +0000
From: Ls Li <lils1102@outlook.com>
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] Clarification requested on safety of `lfs
 migrate` during concurrent writes
Thread-Index: AQHb32JbfY+0KcT8ckm/h8N1AwVXDQ==
Date: Tue, 17 Jun 2025 08:47:31 +0000
Message-ID: <OS7PR01MB11902B49B65F82E851AE8D0C7C473A@OS7PR01MB11902.jpnprd01.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: 
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: OS7PR01MB11902:EE_|TYWPR01MB10146:EE_
x-ms-office365-filtering-correlation-id: 760fecc8-7eee-4277-3aa7-08ddad7b9917
x-ms-exchange-slblob-mailprops: P1EfU6pZOd/OgWJYM3wPibo8k7V8drA7M2F/vbzs0jREtdHyZXcYhx8LnmbArc/BbtcaepHksGgb6hMUGg0uB2li48EZX1EWAP3i7CW+2CJQPk3xm8wi+A3O5dbdfk1Bs3UU4dtXAEL/a+V1p0Ye4v7zMYTvCe9u5SdPOHxZJN2EX0dPw+SRAjV3g5hvK2OFfXgdeF+fCajwUtz7nyQC/ebPH0PtJT5pmhJTf/NuN7sxkLpstF369NkkQh1CU97FQc/A6pBsFPn0phMAxzNVlxgagaKTr1WembkYQ+tVGGreETsWJmsDKcFP0SaMA5qYSMxNM4mRTlyVAmvqQT9Nxw/AkYgcnJdMRWouNIjuYZAzEbuYLz3mDL97FSlK047SyooMMUiAiUDhfcg2vDRJvOycuFY962G9MssUsfCAwvIMDIusZGUq1z8G2VIIa6zQY9kdy9X6ymgXnurAB2tfXIz0aLXDWoCbTYCKdsYTMc9wq52AXULAngKTPIM3CbO7fYtCxGfnZMSgilv1LqWktMMhecXCUwhhjiYEGJgckuKytKiPTuM3vzSXrTKOqUvd1Sap/8tc7SZ8WN0hnZXbWlJ0MTOrC7M+DSpfpAHb/yWDwgp5aWVKuGx9RYdjg3m5OnsNNSebKuvvHw13LitK6Sw8pGShc+UOF98Lvg97dfnOuYtU8SSyeNrd3xieJKSmq4rddUEBQbPe+GmzabNIiLmRt+1lRjFU47K3mPFr8n2s8Jm2EeJAVBDH87YBomiTaRpZyP6kz/H7KsyQtSWdRlO09+OG+tBpoyDoFlOE99+hAT7DrWgZqQ==
x-microsoft-antispam: BCL:0;
 ARA:14566002|461199028|13031999003|15030799003|19110799006|15080799009|8062599006|8060799009|7092599006|440099028|3412199025|102099032|3430499032|10035399007|51005399003|40105399003|26104999006|39105399003;
x-microsoft-antispam-message-info: =?iso-8859-1?Q?EjQkrzkkYoxAR+NoWmbUjDedJwTxVVSg2GlNyzi8bIWS+jc0gPOlfIgqLQ?=
 =?iso-8859-1?Q?wtuPznGrn+v5Iib6w6NrB+Qg+ecf7c/3i5QUk7YSg2RIFTrWb+Rg1MhioO?=
 =?iso-8859-1?Q?l/zju944Jp0KOP8MI28w/JeJi4FPFlKaJcLCWf1XeIo1v7K/hapfSU91Ho?=
 =?iso-8859-1?Q?3i4SL7/aONBSi3DsFKQAY4OM8eO5Vn5Wmr8cRxxHb16UY//p9ZUUmXrDTc?=
 =?iso-8859-1?Q?boS8cKKiXFI70uCBLge3wxL7bD/Ca3jdxiBRxcg5mjGIJN7rB1KGkKXj8P?=
 =?iso-8859-1?Q?mXwjCIh8gIjb6tHrw89ok0KcwSY+1uZEDr7wiy3sdjP3hvaNvxklEnu++c?=
 =?iso-8859-1?Q?AwE/05Ltfl9Vkqj441yVwnzOr9Ykx8HhQ2+2EP+vxSFlqGsux1iOun6E+6?=
 =?iso-8859-1?Q?5NejdkEV6JE/0+ay4sE+VEVU7xlWUY/5kmjluyJEkadnfLHxPBGJghabB9?=
 =?iso-8859-1?Q?cgemt/CQAfhGe9g5hiANURde2WAIBdangp8YxpV1GIrxJAl4fEQYh2oHQd?=
 =?iso-8859-1?Q?SPaSOvryPE4lAR7P/wRgDGly3g24TPquW/qE/WBA7vEUn0JMckrPgjxjce?=
 =?iso-8859-1?Q?bYy9m+e90L5Od72tEBmqYW4PmwVfIb46748niQOSXgguUqUJqQkqd1WpEc?=
 =?iso-8859-1?Q?kNPFWMpcdO7Qx1947q3RU3uKUa4V19txOHOc1GflXeZ6Se/eObt+/WpZ+8?=
 =?iso-8859-1?Q?NFgxHt3viHcHX47w/bOi5q49mWFw6iJM0vspGzF7sKQclm3fKNCpFh/ffD?=
 =?iso-8859-1?Q?dKWCvIP8txnCTid3+pA4fj14mN6tKoqDPNovd64D+KIETphP6L0J7z/lZF?=
 =?iso-8859-1?Q?YmjjWxFpFiX0rjug1fxxdsjZIyRwFySVudkxy42KOEjrDFl+H/rTo/LIQW?=
 =?iso-8859-1?Q?w+Qz06uAmfYJ0FNzhVgbRKaHlHZf4B1lKxCtdAuCRh9xjvy4pGIJHGzz5E?=
 =?iso-8859-1?Q?aUPiPg+etlV+C+LMS2kmgv3xDow99rHF/X6jhNIzuAEDiv8AXX3Drq6Ruo?=
 =?iso-8859-1?Q?5i7jML/ZZenuIXlLcraxbRVU986sZDybKGacsXVV8DoqBGemWRmIKfIgx5?=
 =?iso-8859-1?Q?O+fVEAc8ghPL2tIM3ucZImzh1GXkrHKuRlKTEwD3g3v8uWYiMZgpD4yU1g?=
 =?iso-8859-1?Q?B+k1mXBSxCazKLrY95Z1RBa7GZeRhe9v7QjnmuYyDPGLyv5l1DaLqvZbwD?=
 =?iso-8859-1?Q?YoUn1307/wMshtGHpaHFhhddCXQ5GNLSIvvLjvdMltEFzAdOpWMkSpzPzo?=
 =?iso-8859-1?Q?C3hhiAHl+oqNr0QIPvRTUwGj7NkgC0vBqiLQxVZYpEtQXb044ponodjphp?=
 =?iso-8859-1?Q?+pF5vlx/zcOfXT6OigWr4qZWuq+eDnKN4KEMpNHFVsDU5SmKo5exAqmWyP?=
 =?iso-8859-1?Q?1q2RDF/2U5p2BxjA/8mBBt6Xe6qdbLqY0r0mIJtxiRH6ey8qFcPSs=3D?=
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?iso-8859-1?Q?j/NZInZVPaTmZohe0/tWIGHGwxpUGJN8Ki6UZaBd6uv7waXGJ6H98j7WqK?=
 =?iso-8859-1?Q?lNh1+h8Z2i+ZHhYB2Qi0NY1OoRet4v/FXQ+bF3K+Qp1M0kh1bzZUBSY0G8?=
 =?iso-8859-1?Q?3RvQ7nKwOQkQXtHcf+vZMRg45KuFvjld1mEXJgp42d+CdqrNXj6zRupP9L?=
 =?iso-8859-1?Q?yzN1uzXm94F19L2RdQ29obyoznOKGHuYXXOKf4cBPwgEd3OsLvl5IV/siK?=
 =?iso-8859-1?Q?P7UDiOUsCoWc4vcAN+/8fRA7Nw/DKGTmXubxuABkJha/yKDP2a1sf7ZssN?=
 =?iso-8859-1?Q?qEdieerb/DrCILLng3Dm+qc7UC6xcWa/8gThdHNyahETZsMiVIu//KyO9G?=
 =?iso-8859-1?Q?p3f4ksUj9XZp+VqXydNjvm4eRNsAwgQqOzQ5KnGwRoYtcF31K4Ll1lE94e?=
 =?iso-8859-1?Q?Gz5JSRv9BLNhILIk8Ia1bvSccdxiTdTVBbyPfxOJlsm/MsKncMX6LSUQb2?=
 =?iso-8859-1?Q?cBweNThxF9mwADMP3AHQBq/EWjXtKAo+yAUEBdNmPEeQkYDUbrPfImO4sQ?=
 =?iso-8859-1?Q?LS4Mtjh0tIk1SJidbjeF9LT8Y6jNmYVkhAN5ncTjysf+un/m2j8hjYC8qW?=
 =?iso-8859-1?Q?ncKPO4NbXyE0f/JmG8ZS9RUxCKkIHA9nyMM9hQzafgIthPsObcroMFEHl7?=
 =?iso-8859-1?Q?TSYuCK3KrGNQmHIdKImQ4Nt15Wky18tD9kUiupXgru5S9Rkm3+7/R3RXtR?=
 =?iso-8859-1?Q?wxL41I2JrBjweJ3RHFuzds29dL1r/wmgaJqeGLmWDA7sebd8o342TbUC3P?=
 =?iso-8859-1?Q?k0DR5cy4pdmeamIsmnYobRa+M10vNu2PTesNjpVyRRZVlBWQgA9zFPi8I1?=
 =?iso-8859-1?Q?DzNH2Ys5Zx6QC8XB4NP01a+kBz3f5M6yyKmrhVKzuz2v9MSuyTbBdTSrbg?=
 =?iso-8859-1?Q?k19NWFEtIbBEtyFcIFcspyilfOpYGXw9IHsVTxrybZS4weapuHaDuztF0v?=
 =?iso-8859-1?Q?gS6Fw+hlHUaj1SjJ3UwrPLjRgU9ZY1gTRB8ce47fmVcJfFwxkK4/NQGAto?=
 =?iso-8859-1?Q?iK1YiJGeQngB6x3JGa3llkxC0WVCNH16DQMaVaW6TmyYGwqDC4810OrYZV?=
 =?iso-8859-1?Q?wNtKq8HbiioqYnVbFSUFuvJSTWVJUeM3Ye/ZLQFn47Mr+nN0I7qKAXTW4H?=
 =?iso-8859-1?Q?OgPW64UyboY3i0c+VrT6aDcqgTWUTO45YvDlO/fJEm+R6Sk997T/U5+7SF?=
 =?iso-8859-1?Q?prJ2fVJww310FHNFse9hVgSYdbaR4JmQJLeJw6yo92G5KlDewY6eTleALr?=
 =?iso-8859-1?Q?9oaJlq2EPlpGw+DznrQw=3D=3D?=
MIME-Version: 1.0
X-OriginatorOrg: outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: OS7PR01MB11902.jpnprd01.prod.outlook.com
X-MS-Exchange-CrossTenant-RMS-PersistedConsumerOrg: 00000000-0000-0000-0000-000000000000
X-MS-Exchange-CrossTenant-Network-Message-Id: 760fecc8-7eee-4277-3aa7-08ddad7b9917
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Jun 2025 08:47:31.6895 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 84df9e7f-e9f6-40af-b435-aaaaaaaaaaaa
X-MS-Exchange-CrossTenant-rms-persistedconsumerorg: 00000000-0000-0000-0000-000000000000
X-MS-Exchange-Transport-CrossTenantHeadersStamped: TYWPR01MB10146
Subject: [lustre-devel] Clarification requested on safety of `lfs migrate`
 during concurrent writes
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Content-Type: multipart/mixed; boundary="===============3698265523555589354=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3698265523555589354==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_OS7PR01MB11902B49B65F82E851AE8D0C7C473AOS7PR01MB11902jp_"

--_000_OS7PR01MB11902B49B65F82E851AE8D0C7C473AOS7PR01MB11902jp_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Dear Lustre developers,

I am evaluating the use of `lfs migrate` to perform online OST data migrati=
on in a production environment where I/O activity must remain uninterrupted=
.

While reviewing the help output of the tool, I noticed the warning:

    "(may be not safe with concurrent writes)"

After tracing the commit history, I found that this warning was introduced =
in the following patch:
https://review.whamcloud.com/c/fs/lustre-release/+/13754

Based on my reading of the implementation:

- When using the `--block` option, a group lock appears to be used to prote=
ct the migration operation.
- When using `--non-block`, a lease mechanism is in place, and migration is=
 aborted if conflicting access is detected.

However, I would like to better understand the scenarios in which this oper=
ation may still be considered unsafe.

Could you kindly clarify the following:

1. Under what conditions does `lfs migrate` pose a risk when concurrent wri=
tes are happening?
2. Specifically, if client processes are appending to or modifying files du=
ring `--non-block` migration, what types of issues might arise (e.g., metad=
ata corruption, partial migration, or data inconsistency)?
3. Is the `--block` option considered completely safe under concurrent writ=
e loads, or are there known edge cases where group locking may be insuffici=
ent?

Any technical explanation, known limitations, or recommended best practices=
 would be greatly appreciated.

Thank you very much for your time and insights.

Best regards

--_000_OS7PR01MB11902B49B65F82E851AE8D0C7C473AOS7PR01MB11902jp_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">
<style type=3D"text/css" style=3D"display:none;"> P {margin-top:0;margin-bo=
ttom:0;} </style>
</head>
<body dir=3D"ltr">
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
Dear Lustre developers,</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
I am evaluating the use of `lfs migrate` to perform online OST data migrati=
on in a production environment where I/O activity must remain uninterrupted=
.</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
While reviewing the help output of the tool, I noticed the warning:</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
&nbsp; &nbsp; &quot;(may be not safe with concurrent writes)&quot;</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
After tracing the commit history, I found that this warning was introduced =
in the following patch:</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
https://review.whamcloud.com/c/fs/lustre-release/+/13754</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
Based on my reading of the implementation:</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
- When using the `--block` option, a group lock appears to be used to prote=
ct the migration operation.</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
- When using `--non-block`, a lease mechanism is in place, and migration is=
 aborted if conflicting access is detected.</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
However, I would like to better understand the scenarios in which this oper=
ation may still be considered unsafe.</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
Could you kindly clarify the following:</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
1. Under what conditions does `lfs migrate` pose a risk when concurrent wri=
tes are happening?</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
2. Specifically, if client processes are appending to or modifying files du=
ring `--non-block` migration, what types of issues might arise (e.g., metad=
ata corruption, partial migration, or data inconsistency)?</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
3. Is the `--block` option considered completely safe under concurrent writ=
e loads, or are there known edge cases where group locking may be insuffici=
ent?</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
Any technical explanation, known limitations, or recommended best practices=
 would be greatly appreciated.</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
Thank you very much for your time and insights.</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
Best regards</div>
</body>
</html>

--_000_OS7PR01MB11902B49B65F82E851AE8D0C7C473AOS7PR01MB11902jp_--

--===============3698265523555589354==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3698265523555589354==--
