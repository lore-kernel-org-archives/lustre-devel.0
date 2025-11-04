Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9ADDFCCFA04
	for <lustre-devel@archiver.kernel.org>; Wed,  5 Nov 2025 00:23:54 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4d1QvS0hyRz20fh;
	Tue, 04 Nov 2025 16:20:20 -0800 (PST)
Received: from outbound-ip191b.ess.barracuda.com
 (outbound-ip191b.ess.barracuda.com [209.222.82.124])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4d1Qtx0QNpz1whP
 for <lustre-devel@lists.lustre.org>; Tue, 04 Nov 2025 16:19:52 -0800 (PST)
Received: from BYAPR05CU005.outbound.protection.outlook.com
 (mail-westusazon11020126.outbound.protection.outlook.com [52.101.85.126]) by
 mx-outbound17-173.us-east-2b.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Wed, 05 Nov 2025 00:19:29 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=ypd3eQbOJ0sic9ZiFCiN7pwSKhjLN98yOgabqB5Ee1DD2fPUD6M0Zu5CZM2k/LfVDi8qoC/fnhrtFBS8o2IAUyL+jOtvEJ2RR0aw1rCXEJ6rpAYKSC8I6pA8i9NVt8DNT6S+zrBncUELYcLwRrGDMdbG6JEKNydvbK5tXQVcRzmvaJQp/p0nPpZINfoj9QkZTMIFCVxMfp6mg1o2mEVK3zBZXry5nO4FjXv1h/mkYZOtShwM4UUtpK1NgrRTwRWHe+4sh4Cm6OdzHNSCz1OVHwnM/vbliyFCEWBW+7qw7PRtB3MUfcckMXcvSf8RyvGpF8nPgV3wx461KZChJ8C1Pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=tAVEhMxpSqliz+vi+Mb0tRxbTz60yCp6FkCXcUrCvCc=;
 b=CKlT2+iLE3AgWDHWaJ7RdUessvm+yw7HVP4E4FLH2m7XjWBeCKfjDh0y155eOMpjypsmhX4aobuQ4eoNC8Xy0J5NFMhoocDRDNexPW0U8NbLjWDPiihYB4tMa6nIGQvzFfqN9YBtkjuMnPkgW6Csbly/hdNSdSWRpd3346hEztVCMFsw8fZQTIqdzMBSjTg39HE7LJ1oXCO02Iy9XLtqPr4C/ZGDr8AyZ1WdOhaMZ57JupB91bsdsMefZSFyEcmvzHL99IVe6lXpNJomi4qb8SJ0qnMscQHV/qlwTI9ctisfD/6rp4B5+DPPEt/v4S9HEUYscMcsD60Rc+3AOI6M2Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=tAVEhMxpSqliz+vi+Mb0tRxbTz60yCp6FkCXcUrCvCc=;
 b=VS0umMZn8VIbx36RTzjBM74WyvNW7HwTYNWTc+c74JrdWd/OCn8SSmuMaEji9FrOLBXCC15Sp2I2zd27BH3ulG3Q0DGmU5J4YMEocJcPAkMMjyWaTcQq84dRsIJb3yuQx0DemberD10RAhDRut9gIEvtbEaSkbK60giMzfu8GPI=
Received: from DM3PPF12B913643.namprd19.prod.outlook.com
 (2603:10b6:f:fc00::70b) by CH2PR19MB8843.namprd19.prod.outlook.com
 (2603:10b6:610:280::11) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.9275.16; Tue, 4 Nov
 2025 23:45:36 +0000
Received: from DM3PPF12B913643.namprd19.prod.outlook.com
 ([fe80::1dae:cea7:3265:124e]) by DM3PPF12B913643.namprd19.prod.outlook.com
 ([fe80::1dae:cea7:3265:124e%7]) with mapi id 15.20.9275.015; Tue, 4 Nov 2025
 23:45:35 +0000
To: "timday@amazon.com" <timday@amazon.com>, Andreas Dilger <adilger@ddn.com>
CC: Andreas Dilger <adilger@whamcloud.com>, "lustre-devel@lists.lustre.org"
 <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] RFC: Spill device for Lustre OSD
Thread-Index: AQHcTdE3vAJsRcuMvkipzEc0Fj6IrrTjI9oAgAACKICAAAZWAIAAAj8A
Date: Tue, 4 Nov 2025 23:45:35 +0000
Message-ID: <1490063e84e7e10531a1c07dc47c0ca1e45a695c.camel@whamcloud.com>
References: <CFE3C4C8-104E-4F7F-A52E-21B8957FAC0F@amazon.com>
 <0092A54A-6EEF-4CD3-8AFD-7B0066A08810@gmail.com>
 <D8E0F0C0-1A5F-413A-82EA-F3CFA473D2E1@amazon.com>
 <28B74585-1877-4A33-9218-FD50AE72D33D@ddn.com>
 <437b0b502c6f00cc728b2b4d0decfc44ae7ecc52.camel@whamcloud.com>
 <FD4A7B76-719E-4537-9304-4D59F4E55489@amazon.com>
In-Reply-To: <FD4A7B76-719E-4537-9304-4D59F4E55489@amazon.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: DM3PPF12B913643:EE_|CH2PR19MB8843:EE_
x-ms-office365-filtering-correlation-id: 0485af4f-3596-40a8-61b7-08de1bfc4057
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|366016|376014|1800799024|38070700021;
x-microsoft-antispam-message-info: =?utf-8?B?amNJeFQ2QlNjcFc3RU9wT3dJd3dGWlJ4aUlwUFdNWVJBSzlxVW9aaVY0N1VE?=
 =?utf-8?B?T1VnWUxvbEw5WWk5cXFUMkhZV0xhcFVldHBvMFBrRW4ydHJXMUppdmFTZi8y?=
 =?utf-8?B?TVZzUmkwbTU1VUVocDc2Q1drbGFUZUFTMVh1MjR6dktIWEdmcEI1RVgwck40?=
 =?utf-8?B?RzYxdGhNUGNobTRtTE8zR0dyd1NZMXpFVzRUMlFxZmZMaVlHdzM1TU1OR3Yw?=
 =?utf-8?B?NUhJSml2T3g4WGFxRnBjTXBTcWw0QmsrYUZjaUh0NGZNZ2dQcTRlSXFRV3p3?=
 =?utf-8?B?cHFBK1dyZ0lrN21QVDVLaGFRQXRjNndKVHdZUEJ3UTk5bUxkSWU2djRYNE5R?=
 =?utf-8?B?MitlVTYveURaR2o1bkh5L1JaTjhOTUFPd3dGSkhueXU3aHBmTEpFMlgybTI3?=
 =?utf-8?B?ZW5TdG80Z1E5WUtzN3BiaW9qQ0p3Vlk3QzZLMVBVU2pycldhWmFZU1dkQlJS?=
 =?utf-8?B?azdNaVc0cTl1NWpsMHo1L3l2cG9sb0x5VkliYlg0ZXQzT1lPSUQ1d1c4eGZ1?=
 =?utf-8?B?Ly9pdHpLM0IwbjhqRnJMa0JXb1RGOUpOY21sTXV1QzNjNjZGYnZ1SmpLdVJH?=
 =?utf-8?B?SU82NEVrbkdjZnFNelVVMzFWZjFON3BaTEZpdGJYNU16MnVGVEtrYTJRMW1u?=
 =?utf-8?B?Qi81aS85dlp5aTBUTTl6UDZ3ai96aGRWMGpQVzRaaU5ZU3AxSW9tMnZvRDBK?=
 =?utf-8?B?V3VUMXB4WUcvMXR3U3h5cW1pTVlzNzYxK0FvNUxaTCtqSE9lb2xvZWpHRmta?=
 =?utf-8?B?Y3hKNGZxbGhlNE5JZm5PQWRJQmdsMGRJUXU3Q2hOMEZxY2FWUW1nV1F2OHd3?=
 =?utf-8?B?djJpRlB5WFdLVk9aWnhyaHFlQkNxZ2xySzloYlZzY1BRZnJVaGttSW9GK0F5?=
 =?utf-8?B?Z2Urb1RYdmg4VlAvNGt3Mm9jcEQrMHZEOUsyUmFyZ25yUUdnY2h3L3ZHQTlj?=
 =?utf-8?B?ekc5UzVnRkxTNFFUVWdlT044SmVZQW1KSkp3Z0RkWHNrNHFQSjU2NisxYzdC?=
 =?utf-8?B?NlZ0WVBYY3FHakVKdzhVRlAyTGtxT3RYWVRyc3ZUOTZQOGNQeGVPRnEwNGJh?=
 =?utf-8?B?Qm5rcFhmaHdnQ01QZElSdDhVRmlmZXV4NFJpL3c5N0luTUJKTnZtMXNlSXh3?=
 =?utf-8?B?N3Nqa2dzbHhxUkkrQ0FxRzdQdUIzZndHeGx5bVhCOG9raDMwWkFycHZxZW9P?=
 =?utf-8?B?TTJmeC9ibEJKTTBscFAzNzhCc0dJTnFJdVgxdnYwMVpRQjFFMkRDdVZzNjJv?=
 =?utf-8?B?dFVRNEpsNzJsb1hkMmhJV1NPK1pnaTkxaFA5cjdOUTdyc2tmZVh4dkkzYjZL?=
 =?utf-8?B?bml2bU9BTHhkWVo0RlgwTUk2QWpZUDc0cUtlN3FmMVJpOWdXa2wyUVlBb0NF?=
 =?utf-8?B?dWtOaU1wdmFCaFJUS2I2Z3ROVlplVWZaY2NBenk0L2o0S3lnZnJHOFhLdmNl?=
 =?utf-8?B?T1FuMU93S1QvbG1oamZLYmdpS2pKTHlPQlQ3WGRYQVpHbVN4cFAwa0NRL1Y0?=
 =?utf-8?B?TEZ3alNCRWxBRUFEdG1jcEZGZ0lFTkQ2aEc5SkNBTHQ3V0REbisrMFZSL3Ru?=
 =?utf-8?B?dlhzQThxRmNieTQzeGRJNjJ4SGZwZVlHZ2V6cTdMV1JVRGo5TGNDa0tINHZU?=
 =?utf-8?B?MFJmWW14a1JkT01BWkN4MWtJeHpZOU54Z0Jmbkkya0dicWhJeFQ2bU40SjVS?=
 =?utf-8?B?ZnpkdCtKNnZzOXhPZUw5NEtFbFkyT1NMYlZSUklhNEphTGpUWE04RzExVUY1?=
 =?utf-8?B?NnJFTTZGOWdidDJJZ1RUemF4Q0JVc1NMQkt1K0VSM1VGWVg1UzBQYXlPcVpB?=
 =?utf-8?B?ZXduaFM1eWdPS2lJM1VTTU0yYnJxbWFSTVA3SWs5cDJVcnc3TTV3YjN0S2E3?=
 =?utf-8?B?TnBXc1pzM0lpOTExY0VmbHh3UXg4SmRGU1RUL1hJZ0h4VTFHNUd0dkhVYnE3?=
 =?utf-8?B?cVhNNDhyaFJndHlwbVRUQmlQSmdpbkVFYytjdFBUdjVZQzl2cCtQb3hRTVB2?=
 =?utf-8?B?NXJZaDVqZDV5eTc3RkowV05peXkwN01TbW5SOXJlamYveVh2aVRCeFpGY1o3?=
 =?utf-8?Q?Ll9LMP?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:DM3PPF12B913643.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(376014)(1800799024)(38070700021); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?V2FUOWtodUE5OFA0Q1QranJ1K1NMcU9IaXJzb1liRy90NFBlUHZCUmsvK0Fu?=
 =?utf-8?B?ekQ2TDdUNFlad1NINGtnZHA4Rnh2eFdYMXRqc0tJRVN2dEhrVUMxZXB5V1po?=
 =?utf-8?B?N2libHg5b2EwTnphZUFGeVZiYjVWb0RLMU1sUG1FK292TW1md253aWVmNmNL?=
 =?utf-8?B?Sy8xZEE3UzR1RmY4bHk2blNkQXljSHNPWDI1VllVNUNBODVhR3hwOUVSa20r?=
 =?utf-8?B?Vk5na1JxYXJ5cGk3Q2dYem9kRjhtdGpGOVJIL056Q3VxakRqVUxLMTkxWEFl?=
 =?utf-8?B?NGRxaUtXc0RIOUxubXZxcUlOVy9taWpFd3QrejhKdk9BN1JaV3hUdC9pcjFM?=
 =?utf-8?B?aXRWWGFVMGxNdkpUTm9wdUtNM1gwd2t6Zmx6ckhYTlM3Sm04eTlyTVVzcnVu?=
 =?utf-8?B?YythaGhBWGxkUkx3TW5HZHZaeG5oK2hOdSsyZkxZYmJYVkJ4S1F3dTRMK3hj?=
 =?utf-8?B?OWNTSjhEajZOTEpvbjNrOXRNMzNXNnNocHYzQnpTb1NhQXF5QzNUNG05Wlho?=
 =?utf-8?B?eUJ5U0gyWlFuZ1Z0bFg5bmRJNFlGQXNwclJtbG5MMEh2amh5QnlueXZxWDZ3?=
 =?utf-8?B?RU5qVnF3N3ZqNU1rSUFWZWY1ZU9WblA0QW1MSXdsM3FJd3BucDE3SHMxK1JC?=
 =?utf-8?B?VnFPdTZFZjNHaGx0SW51c2tNV1J1dy8wZUloZ3pJNVhkRnJ6SkVZUjIwTVpR?=
 =?utf-8?B?Yzd2T2l4cjhjUE5YaDhVZXEwbWVoQ002Mk1CK1ZRb29hbU1LYU9UT2hBSmV5?=
 =?utf-8?B?KzA4OHpaSXB1VXNaTzZMTVFtMEM0WGJvWFIrYUZJR1dRb0IvTVhpdjFvWmZy?=
 =?utf-8?B?K0gvMytyNHBwYkJPK2VsNVJQcTZPc3JWTGNscnU5WUpkZEg4SkwwVEtwcXlv?=
 =?utf-8?B?WlJ1NFRnZW1VMlNMdWhXSFJWcnhtcDZGb3hZT29vdlJXU2pCWktibVIyQkt0?=
 =?utf-8?B?bW9Ha3UzNkNhOVozRkRnS09qelRCbkd4SlhESnZ4Rnp5OW4vTjZhSVpENGdM?=
 =?utf-8?B?UStGUnJrVGxhU2hrT1p5WEFTQy9DNFlHRGxlOHNCMWs1WE9LdE9pVlBJWDhU?=
 =?utf-8?B?MStTVHFuY2xObHdWblJkM1ZzWWFvdEhEanVMNDFMazhBMkh3YmxvdmlOQ0pS?=
 =?utf-8?B?bE92aXZyczRnZzlSaSt5YTE1TnlzcDhZaEd2bmg3ak5SZ1E2a2poK0pWdUZs?=
 =?utf-8?B?ajBCUGhRMDVZNTIxbXFmVzJ0RzFjYThFSjRTaHo2SGdzQy9aRXhnd09EK0ZD?=
 =?utf-8?B?bW1tZ0k3TTZSSEcvSWJYQTlhK2xVZUM4TGhlZEwwd3k2SEE0OE9yelVMWTJG?=
 =?utf-8?B?TjJnNzZ2eWhncXZ2bi9LUnNheVFFZ09FU0dlM1NYcVRMdmhWMkQxTjdibVdZ?=
 =?utf-8?B?RlVzWlNab2U3bjgyU0M2RDB6TldJMkhXWUhZM3N2K2hqdTVsbnlMenZia2FC?=
 =?utf-8?B?RlR4cTFmUGdWS0tQd3lNbVhqbmx0VUFDeG41VWhNQk84diswRXVieXg3a2ZZ?=
 =?utf-8?B?eGJ0M0RpYnJzcVpOL05CemVSbVVPRWJXWGkraVgwTktxWSs1Zm9nRkN6NHJv?=
 =?utf-8?B?OElLMjRiYW45VzErMWR5cDdRNVVVeHRqSEh3OUNDdWMzUzFEdkd1b25wZXk5?=
 =?utf-8?B?MEl0dlJjMy8wLzRSKzlCZHRmV2tMWHJ6cnVjVDhCdWJBN3JXQWc4Zlo1T3d3?=
 =?utf-8?B?OG9HQXZ4bVVtRjNUM2pxa3FKTE5BeCtkR01aT1prQVpoMWFrY1RlY0tPckhn?=
 =?utf-8?B?cTR6NjR6akVWZndoWHRpQlhieUNtU0xrU1ZPT3k3Q3ZBT241Q3hDYmtJdzdF?=
 =?utf-8?B?Z242UlhDU2R3VU9XaUdtbU04ZTl2Q1ZjeWl1ZTF1Yjc3ODRHWTM2NEQ1NDNW?=
 =?utf-8?B?S2VtcVEzb28yVnV5U01Qa3pvdnlqbzlqWExlRDBiSjJYRGprRGxPdUdvRnNS?=
 =?utf-8?B?VGgxaUoremY1bm5YRXo5SjBqM1k2dEgxTXNsN2ZwcVlnc3o5cEgzTkNmWnEy?=
 =?utf-8?B?WDZvMDd2bkdZQjJzT3cvSEhiUldqNXMyUmxEUVZvZVdTQzNUaDJYTUZhSEox?=
 =?utf-8?B?WEJiVUU1QWtTSHE5NDBwbWU1SW1jMDhEL0o5UnNEdXN0NjBpTGEvTVVPWGJQ?=
 =?utf-8?Q?xqy2U9Y9oLtfocviehw3MZ5V8?=
Content-ID: <1EEC887E3B694042AF03E1CF56D39AF3@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: C9HtH8LiPvb/WjJ5owDelIZ5WkN+bvuYXsnKEBBmeRrPsNQ8UboaHhKfIUyVAD0Hx2auSd2uL44ppcdq9nAxBKCfIvjYEd57bmpsqOI/9mU+pgjK+6L8w++xF3Llil7xR5/TPHZNOX5BkD61N3Jq+rOqtRM1igrdCJ05IGyIetUZqHsvazrCoEIt/mo0bI0EAz1cM1OTt+rBbINMNm0wDYQSwAVaRPdAmw8+noM4IFHhK6HeIrkUHV/Vz3ujVWfeqUF24r0b7c7EKRikN2cjhLqVSYcJItvKxvv/9EncN+WjsgNfJ+lk6m7wPRJcUsVci19tfSjqUbo+ZdOLH2fiy1WDSYEBR4FEpzm8HsUP6kvDI0MJYN53jBXtrlVnNxbLv8bPAGxc5RsXXIaEN9yKcqiQbfHJL4i0wdpAoDfOoWk3xvY5CJHAsq/95wkynrYf8weN9xinFuKg5uUhv6DJi1v3zFmzrcB3p3NDaxWu9KZVadbuOkxG5Ba4YkeLCTy14s4NeyjphT6eeM1IzSuzJT3oWbqTM6N2625E+5vjoWW105YUvsBnYES+U7eSCeS9e7pNCqxzWdBuiuH8mWy35w+vkcEPoXYgvvyqJ7Xr4qdcINLjk02lRlad7WHmOAc8kD0QZaPbucJDx9RDFBaI889FNx6r8mQV3l6mvvTbqFs=
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: DM3PPF12B913643.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0485af4f-3596-40a8-61b7-08de1bfc4057
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Nov 2025 23:45:35.7976 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Qkmml4bE1JG64YzKWuhzwyQY9c5DcQnukWnT9/oyL/nG2rOV/ntPNkrKFwytlvx/
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH2PR19MB8843
X-OriginatorOrg: whamcloud.com
X-BESS-ID: 1762301969-104525-14772-15867-1
X-BESS-VER: 2019.1_20251103.1605
X-BESS-Apparent-Source-IP: 52.101.85.126
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVoaW5gZAVgZQ0DDZOMXQKC3FzN
 gsKcUyxdAy2STVPMkg2cjcwtjSwMJMqTYWAPHw2v1BAAAA
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.268714 [from 
 cloudscan20-253.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 BSF_SC0_MISMATCH_TO    META: Envelope rcpt doesn't match header 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_SC0_MISMATCH_TO, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] RFC: Spill device for Lustre OSD
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
From: Oleg Drokin via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Oleg Drokin <green@whamcloud.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

On Tue, 2025-11-04 at 23:37 +0000, Day, Timothy wrote:
> > > If we can implement a no-transaction osd-vfs, that would expose a
> > > lot of flexibility for other reasons as well. Possibly the osd-
> > > vfs
> > > could
> > > implement a journal or other logging layer internally to make up
> > > for
> > > lack of transactions, whether initially or at a later stage?
> > 
> > That's actually an interesting idea, but probably not very
> > practical.
> > The journal itself is probably not really feasible with VFS api
> > alone
> > because you need to touch journal together with whatever it you are
> > modifying, unless you update the journal first and then everything
> > else, but that is likely going to be slow due to all the overhead?
> > That's probably why all the journaling filesystems hide the journal
> > inside themselves out of reach for the VFS api.
> > Of course VFS api could probably be extended eventually if there's
> > a
> > good justification, but who knows how long it'll take and how the
> > final
> > agreed upon implementation would actually look like.
> 
> Databases do this kind of journaling and they use normal filesystem
> APIs. And they can do this with a similar performance profile as a
> Lustre OSS or MDS. OSD is pretty much a database on top of a normal
> filesystem. So I think it's possible.

I think databases do it by pushing everything through the journal
pretty much?
I guess the alternative is the rename semantics where you write the new
something as a temp file and then rename, but again that's of limited
usefullness in our case?

> If we had a no-atomic-transaction osd-vfs, we could perhaps use it
> for stand-alone MGS. Before ending each write transaction, the osd-
> vfs
> could fsync() the whole filesystem. This isn't feasible for MDS or
> OSS, of
> course. But performance demands on MGS are low enough (I suspect)
> that this would work.

But why would we want a special osd type that's only suitable for mgs?


_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
