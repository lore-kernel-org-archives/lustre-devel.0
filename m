Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id F2BC1C433F5
	for <lustre-devel@archiver.kernel.org>; Mon,  3 Oct 2022 09:08:39 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mgw472hRQz1y6K;
	Mon,  3 Oct 2022 02:08:39 -0700 (PDT)
Received: from NAM12-MW2-obe.outbound.protection.outlook.com
 (mail-mw2nam12on2051.outbound.protection.outlook.com [40.107.244.51])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mgw4609DGz1y2N
 for <lustre-devel@lists.lustre.org>; Mon,  3 Oct 2022 02:08:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=bup5bsWL6pLqKEZ73oKscjga40q2WhZOg3VgjY8U+OcmxHrNCm0k5dRiKVP/ObNGBUhRh6UfEn3DR1VohzVGuXrVyvrVPSeD1DqNi7gcmSHhraggnjsck8U3mcN2E9QleEbMneUmMnBFuFLwGFnhdpxR85vXf857utLQ+KGHbqpOAvwSZGkIrd9FoFcHKr1ax+20HpD/G9+2zowwihG0K0pt+Gk5rhfSGIEeBm44FVfJYgSsYkO+Ah6uLtvPhmAl5HplUWxGKP1aWbG4wr1GqDbAwKdWbfQxIx1UHYyvZ/fn1yE5MDgyqXsxOJZAbzxGpW0JxYXKNeXN+L7ZqJp53A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=N27pEIr3NIfiJrvKmkxtTwImY5dpmyvjImqq8539KgQ=;
 b=lFno5AFQ0IUOxdvaNIUdz830XarILSoRUkqvhY5RhgcBlF5EaBkemdac89Tt28+9DPGc+HVxynCQZxDAJuDerv5/4pxO6DLvJdhfaScEfDTpAzY2qo8cJswZwCs/IFfkQ6PJwK/S0oD1gEwQpE6f5e4qKiSAE7f8eJxhfxFR2TzZbfyOiORksBkNPMBSWNa/AJt+gCLaWAJeGqTQ0KwjAexg9HfdDqzOCGxCOeLCgARKpLU6l5c1F0hg2ZQU7slxfDB6bdukSCExszPmGjkJ7/SOr6Fe2ww/tB3ObG5ucBRB+3f+1PZyvsdIX2EJrGPtvWTH/jInePzo/27f0rgP7g==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=N27pEIr3NIfiJrvKmkxtTwImY5dpmyvjImqq8539KgQ=;
 b=I0x1ode6jNuOYGFbMOsOSVgB1ABtR4Lu+ZaCIVtdzX5x/u1Wl9gtnjTGIfvzzcN6gkJUAatCIDjbxJk0Rzl8XXT2j5gJOJ4EdhpLLq69l+B6bj/1UzBaO+iTob3/aiEXbtAU7BTBPuHbqI85J+zk+W/LIxiWBcomUfMXWwCnr50=
Received: from DM6PR19MB3769.namprd19.prod.outlook.com (2603:10b6:5:229::19)
 by CO6PR19MB5338.namprd19.prod.outlook.com (2603:10b6:303:135::10) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.5676.30; Mon, 3 Oct
 2022 09:08:34 +0000
Received: from DM6PR19MB3769.namprd19.prod.outlook.com
 ([fe80::fd95:936b:16b7:2535]) by DM6PR19MB3769.namprd19.prod.outlook.com
 ([fe80::fd95:936b:16b7:2535%3]) with mapi id 15.20.5676.028; Mon, 3 Oct 2022
 09:08:34 +0000
To: =?utf-8?B?w4VrZSBTYW5kZ3Jlbg==?= <ake.sandgren@hpc2n.umu.se>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] review.whamcloud down or me being kicked out?
Thread-Index: AQHY1vS+nNGAMGOQLEmr9o4fpRPTDK38PIYAgAAC2ICAACIjAA==
Date: Mon, 3 Oct 2022 09:08:34 +0000
Message-ID: <7F4A3920-43C0-4EF9-8D7F-7704FE96C2BB@ddn.com>
References: <21061178-bc35-8d8e-e741-ad2046a1b3c2@hpc2n.umu.se>
 <B101335B-23A2-4099-9D00-8832F654DCA4@ddn.com>
 <2b52aff5-9bec-1705-f77f-5daa2d8094d8@hpc2n.umu.se>
In-Reply-To: <2b52aff5-9bec-1705-f77f-5daa2d8094d8@hpc2n.umu.se>
Accept-Language: fr-FR, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM6PR19MB3769:EE_|CO6PR19MB5338:EE_
x-ms-office365-filtering-correlation-id: e82bb70a-a340-44a9-0393-08daa51ed987
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: Vjv7yPhtKYNKBMTMzdodK6cO3/dIerzsrYNXFS7OkSSeZV4wec9E9Yo3wEg3/VoUalAf/UJsw0ZWKGXdlNIuibdv1nC7SkRGQ10Db3Uhfxb6mDrDbca2X03rXR3dvLd4sz2mKSEX5I3Oxr905Vyye8qNUWWJ4QVp989OWbOFOMK/4xuJvGkQ39Ar39HA/HDOM84woIuTZN2PZjLvX/Hrc3y0AeP8Xg/BH56sAIhjMpI948TS9Ivkq/UZAiX60VSLFoiTeWN1J8sKdAsRR0zS6T72aSpsDsEqfohumaplw56UwkPSR0IyIi5iGV+GNOBR1vv4sst2fK6NiaFaGdjrkdx+qZP6S3imDbeq23vbVFnAQd5gtEoibqdhBBRptfkUxHis+leeGbXIMo09B0nd4ShIIK4sPuDaySPWqF9L6dTZ/M4KcDwFowW9GesxXwJ1NAvpyyBuzg4iZgLOLePNnzAjkboQzENeNaezPDgSLmH3nxKVrX4oFWyackui+alB3f9P5QukTp54UcYei+vpysIIqV9kQite96EI/kyJVpuVFB8MHMBHSx/irHx+7fqT5VjYVPitPcnjdUoIfi9UJ+/sBoSj6M6DfrAkSWYekr4IIbFBPHETohJ8e6Kooy9OVzTlym8pkVqk9Al+HQJytiMtEOP5Oog7CtM/FBbjCJ9laB+Zbg+SLtgrY3rgm0jvRt1G3xsz0e+VX6eHQ/gjKyhyj12kmaDyqfF1TOcLRYwnH1X4SvIWvojBvujMsOWjp7ldup5NZvoG+nvy5rNW4X8ecgwi9KTN4oNJVd02Sd7ZAF72gGBtskTW9lGTAyIRptgu2HF7v/rk0dxDGSon3Q==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM6PR19MB3769.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230022)(4636009)(346002)(376002)(396003)(39850400004)(136003)(366004)(451199015)(6486002)(966005)(71200400001)(478600001)(91956017)(66556008)(66476007)(66446008)(64756008)(6512007)(8676002)(186003)(33656002)(26005)(4326008)(66946007)(6916009)(76116006)(8936002)(5660300002)(38070700005)(122000001)(2906002)(66574015)(53546011)(36756003)(2616005)(316002)(6506007)(38100700002)(86362001)(41300700001)(83380400001)(13693001)(45980500001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?aEg1ZmJRcFd6L01ERERFbWIxVWdVK1BYcUZ5UFgxUHpaYis3SWRmTjdSVkNE?=
 =?utf-8?B?TnhxRThmTHdiQmJFTnpwMTVSMGhhM1ZsS1AycERHRm9WcWtuUWpJTkFPT2dH?=
 =?utf-8?B?QlcxR2IyZnRkMUlkeXM3cTlHbUhoSGhoK3JHRWxRTVpaeWFIU0VaZjVYQmtR?=
 =?utf-8?B?czY3Q2IyZEJEM2VTdXRKNDBuTHcyK2xrU0pwVWJ5T3NmSXIrZDAxOUlKdjEz?=
 =?utf-8?B?S29lNXErOGJCQTVqT29sMUR2SW81YjdFdWs4ekJ6L3FhZzQySGxHeGlCbmI3?=
 =?utf-8?B?aS9TdkdNNnppenRUNGRkZ2hNSDRQSjA4aHJDOTBRSUd2THVqRFJVMDUzc3Yw?=
 =?utf-8?B?RE5NS1RlTjdtaXdnbGNLSUMzZnhERGhMbFY4eWdqL0ZoSHoxdmVsSTZRSW9k?=
 =?utf-8?B?QXF0b0VUMG9jZ1hHTm1DcVorcDdIOEd0WXpDaHJtT2lnMVlnU1lPWGhLRkF6?=
 =?utf-8?B?RDlQWk9LeElrUTArOGNQUFdHeXd5QkdRMTNZOXQrYU5CUmp2R3R1bTg1cjRz?=
 =?utf-8?B?aUFJTGc2cEZjbnk4NURpejI3TE04ZmFGNWpMQkh6THF4TFFJT0lreWg0cjdj?=
 =?utf-8?B?M00zYkU1V1lqdjY5MG9aUTUxZHRQNWYvVGtpYmY5aGpBQVVHNllhLzFqMkZT?=
 =?utf-8?B?UVNLSUxhMU5qVCt0YXJtVmtIM2txaEk3dXE4QVBpdzQxbDY0SlRhelIydTVH?=
 =?utf-8?B?aEgyWnNTSUltSlkybjIwNnIrMTdYalp2UEdKUEJYd1VoeEpZWEdyM1R3TFRD?=
 =?utf-8?B?ZVJSblE5MGEwUDFZdkFWb0NZc0FvUG9EbHpMSGRhQzhhN2FuL2F5TDRrWmo3?=
 =?utf-8?B?Y1VxRG5GMG5NS0swODFXU283M29uUlA2OW1Lc0YwK1pIT1dZZ3JyVUJvelpD?=
 =?utf-8?B?alBESi8xMVBaN1ZGUlhQUkVVd2lSQllubkY3VzliOFlxSTdGVXM3M1NPL3gw?=
 =?utf-8?B?NzE3ZWlMNW5LWHh4WjlHQUV0S0NIUGk2N2ZPOWcyRjJJNDlKVnl4MDNYbVQ3?=
 =?utf-8?B?dFBpRkxJejNiZ2dPK1ArNjJrQXVqVWxZcFNWL05qMDhxY1crRk9HVERFY0V6?=
 =?utf-8?B?ZUE2Mlc5Zjk0OFRDOGhTSFY4Q2ZIbldsZ0VXQlJtMTlQL3ZHTnA0ZzdzdWNJ?=
 =?utf-8?B?QnNNN2FDTTlaM1h2NkdBdGpDMGNHMWQ1S3JWQldQNzVUU1pPWEY3YlUvSlFY?=
 =?utf-8?B?eXRoUEZwZlJOWXd0NVNSRjJic0Q3VFloaGNLcG1uK09wdTJ3Zi9aVlZGZ2xZ?=
 =?utf-8?B?VHBPbzRvbE0rNCt6U0pJOVVQOWFhbW96Q2tWOC9kVElTNHM5S1kyS1lQRTg3?=
 =?utf-8?B?L3dmWWpJM0hzcjNGYms5dzhSWHdwcC9mTFBFQ0hyRmpyZy9RZ2Q5U3BYZzRY?=
 =?utf-8?B?VjFBNllWL2pwOW5BUVNzcGUxV0FyNloya216WkdwWjVsaVI5M1d1d3hmOHZ3?=
 =?utf-8?B?eldLVXVoOUUyMGUvV1BSQVlDaVpaWEdGeVFydm55dTZjMGN2VkVYaXdlcFBm?=
 =?utf-8?B?enJ0c1U5b3Z3cXRNdEk4WktMc0JYSExjdlN2WkdUYzlNcEhsRGdZYVpXSHJ3?=
 =?utf-8?B?SVdHWnlRS24rcVZKWFdVK2RCNkpGTkNuZngzUmQ3aFp1WURjRElVRWdyRnZM?=
 =?utf-8?B?NjVubDZ3N3N6eHEzaTRpNFNGM2x1YjhxMmpaK09KYzNKVVRJR0tKa1d0Y09s?=
 =?utf-8?B?Y3J3TEN5YjBOTm9OcHpENSt5OTBoRE4zbHFEemlIRWIwcGtvNktvS1B4K2Zl?=
 =?utf-8?B?ak9NcGgyU2o4NUZ5Yk9FNTBQRUFQR1ROeTNiN0N4Z0VQSnc5eTdxWFpJdXBR?=
 =?utf-8?B?MFpVQ2dWNFFGOVhHYmk3alh1V2JsdmRDQjZRT0hnblFpMHM1QVNUbW8wcmU0?=
 =?utf-8?B?eC9HeGwybjNVTkFPdXdsV1BtSVNYOW5nc21MZDAxY2NBWXlSS0VqRGJkbU5U?=
 =?utf-8?B?cVc3WlhLUjd5TUt3NU9YR1J4N2dReUUrK3VUTlZiSjdUenF0NmRSaGhDRDE2?=
 =?utf-8?B?MzJ6RmRtN3kwMlpuRVMyWUR5UHVhdm5EdzJGNkxYdGI5QVpvM1lGSXdURHhJ?=
 =?utf-8?B?QzBqVSthamE3ZHVSaEM4bzBRTkxZcFRnQ2lpalF3eElNTVU2dWVGN1hWQlAy?=
 =?utf-8?Q?QuMg4V7TAnx8DkzsKxWUXmtIm?=
Content-ID: <B1B3B47D0DA87D4EB6E448FCB8AF9908@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM6PR19MB3769.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e82bb70a-a340-44a9-0393-08daa51ed987
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Oct 2022 09:08:34.3140 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 3+/avIvOPZ01nlEHlvH03OI10gDbL5+vigg93lH+e8AUFy2Rl8JoJ4IVYNC4IaR0AahE5I65rh9p+LOXfwnYBQ==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CO6PR19MB5338
Subject: Re: [lustre-devel] review.whamcloud down or me being kicked out?
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
From: Sebastien Buisson via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Sebastien Buisson <sbuisson@ddn.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

RllJIEdlcnJpdCBpcyB1cCBhbmQgcnVubmluZyBhZ2Fpbi4NCg0KPiBMZSAzIG9jdC4gMjAyMiDD
oCAwOTowNiwgw4VrZSBTYW5kZ3JlbiA8YWtlLnNhbmRncmVuQGhwYzJuLnVtdS5zZT4gYSDDqWNy
aXQgOg0KPiANCj4gSnVzdCBteSBsdWNrIHRoZW4uLi4gOi0pDQo+IA0KPiBPbiAxMC8zLzIyIDA4
OjU2LCBTZWJhc3RpZW4gQnVpc3NvbiB3cm90ZToNCj4+IEdlcnJpdCBpcyBpbiBtYWludGVuYW5j
ZSB0aGlzIG1vcm5pbmcsIHNob3VsZCBiZSBiYWNrIGxhdGVyIHRvZGF5Lg0KPj4+IExlIDMgb2N0
LiAyMDIyIMOgIDA4OjUyLCDDhWtlIFNhbmRncmVuIDxha2Uuc2FuZGdyZW5AaHBjMm4udW11LnNl
PiBhIMOpY3JpdCA6DQo+Pj4gDQo+Pj4gSGkhDQo+Pj4gDQo+Pj4gSnVzdCB0cnlpbmcgdG8gcHVz
aCB0byByZXZpZXcsIGJ1dCBnZXQNCj4+PiA9PT0NCj4+PiBzc2g6IGNvbm5lY3QgdG8gaG9zdCBy
ZXZpZXcud2hhbWNsb3VkLmNvbSBwb3J0IDI5NDE4OiBDb25uZWN0aW9uIHJlZnVzZWQNCj4+PiBm
YXRhbDogQ291bGQgbm90IHJlYWQgZnJvbSByZW1vdGUgcmVwb3NpdG9yeS4NCj4+PiANCj4+PiBQ
bGVhc2UgbWFrZSBzdXJlIHlvdSBoYXZlIHRoZSBjb3JyZWN0IGFjY2VzcyByaWdodHMNCj4+PiBh
bmQgdGhlIHJlcG9zaXRvcnkgZXhpc3RzLg0KPj4+ID09PQ0KPj4+IA0KPj4+IEl0J3MgYmVlbiBh
IHdoaWxlIHNpbmNlIEkgZGlkIHRoaXMgdGhlIGxhc3QgdGltZSBzbyBJIG1pZ2h0IGhhdmUgYmVl
biBraWNrZWQgb3V0Lg0KPj4+IA0KPj4+IC0tIA0KPj4+IEFrZSBTYW5kZ3JlbiwgSFBDMk4sIFVt
ZWEgVW5pdmVyc2l0eSwgUy05MDE4NyBVbWVhLCBTd2VkZW4NCj4+PiBJbnRlcm5ldDogYWtlQGhw
YzJuLnVtdS5zZSAgTW9iaWxlOiArNDYgNzAgNzcxNjEzNCAgRmF4OiArNDYgOTAtNTgwIDE0DQo+
Pj4gV1dXOiBodHRwOi8vd3d3LmhwYzJuLnVtdS5zZQ0KPj4+IF9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fDQo+Pj4gbHVzdHJlLWRldmVsIG1haWxpbmcgbGlz
dA0KPj4+IGx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnDQo+Pj4gaHR0cDovL2xpc3RzLmx1
c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1c3RyZS1kZXZlbC1sdXN0cmUub3JnDQo+IA0KPiAtLSAN
Cj4gQWtlIFNhbmRncmVuLCBIUEMyTiwgVW1lYSBVbml2ZXJzaXR5LCBTLTkwMTg3IFVtZWEsIFN3
ZWRlbg0KPiBJbnRlcm5ldDogYWtlQGhwYzJuLnVtdS5zZSAgTW9iaWxlOiArNDYgNzAgNzcxNjEz
NCAgRmF4OiArNDYgOTAtNTgwIDE0DQo+IFdXVzogaHR0cDovL3d3dy5ocGMybi51bXUuc2UNCj4g
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18NCj4gbHVzdHJl
LWRldmVsIG1haWxpbmcgbGlzdA0KPiBsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZw0KPiBo
dHRwOi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5v
cmcNCg0KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KbHVz
dHJlLWRldmVsIG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwpodHRw
Oi8vbGlzdHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5vcmcK
