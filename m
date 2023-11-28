Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B14C2C07CA9
	for <lustre-devel@archiver.kernel.org>; Tue, 28 Nov 2023 20:04:19 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Sftgz1bflz1yCH;
	Tue, 28 Nov 2023 12:03:59 -0800 (PST)
Received: from outbound-ip191a.ess.barracuda.com
 (outbound-ip191a.ess.barracuda.com [209.222.82.58])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Sftgs6bv3z1wWs
 for <lustre-devel@lists.lustre.org>; Tue, 28 Nov 2023 12:03:53 -0800 (PST)
Received: from NAM12-MW2-obe.outbound.protection.outlook.com
 (mail-mw2nam12lp2041.outbound.protection.outlook.com [104.47.66.41]) by
 mx-outbound8-51.us-east-2a.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Tue, 28 Nov 2023 20:03:50 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=mExYDTk05DDzjVo0YFzoejFoIZPcBNLJwGxuPcb+p3Sc7x4qCN3rRJPi8oCxwZ+nqw3VX6jcTkP+rtLo3BqDWqQV82o3g7Vk97+DAjDRIh72f11RZ4DiZxaC3i10QMeO46LKQZ11ZxC9RX2OuAEMZ6eoYqdYBFqwOoPdoFznqEdFkbU0lpDVSoWN8MHj89Zz9jdpWAOqfwAzzckdpZTn0RRSW+ds7H4/P/mEQ9e0jIWwxly0Lr56XB9zJ50fk8IIEMobN2OkrYgJu9VTcbozrFuUqRQNZwdrqc5nSIWr3adttk26cXL2jti0vbgUbIY5+Us/1VJ+dtTd0qNK1WxlMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=cV/qVh221WvK3QVOuy1QRm4figmpJWivsU+h4rZGX8w=;
 b=BSSwb3aaNFnekEQpbYei7vtVN6MOX4sxD2H3LUQDaOdOZf9ULn6q5DgvouUqrk/ZBi/+Cm7UXXbwBPz1tohjzln5OX0byyRMAdSN9KMv/qGno5Ipanemz0JZ9IzV5Pt8bkDzfSsxo6k1Cd1dQCmWT73UPhpv1yM8pk4KAH4vUXQLm6Z/xXV6FtymJoMMzEOPx2GaQjrlgoVbss2D24+zW4wp5JITc4FZPgGT2k3a8fbbQmq7TEM2TspkvJLTUiH3N+0WDBlyQAPS6foM2VLJSXTBD8wHcfEFgZmojOBFDJUkxFmXpdt+dTKDBxL5qiMzJpxUsvV03rb/5HCLP8KSEQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=cV/qVh221WvK3QVOuy1QRm4figmpJWivsU+h4rZGX8w=;
 b=w+In7XHRrpEf7w4jlqwXBpWhkQ7dplC4VnZk1xDCegt52BzsQN2T8o0O/nfc/PpCDb54hCo2KbTFGl8VapQuKV6HgACsUj1WOy9mEbl2f0JgSU/pPAituCe2ZeISZ3jXRiML7KCminGsJqJKulaVlWTdpQundj1G7fmaRm7xVjc=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by CY8PR19MB6962.namprd19.prod.outlook.com (2603:10b6:930:5e::6) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.7002.27; Tue, 28 Nov
 2023 20:03:47 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::5159:beb7:af36:75b3]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::5159:beb7:af36:75b3%3]) with mapi id 15.20.7046.015; Tue, 28 Nov 2023
 20:03:47 +0000
To: Cyrus Ramavarapu <cramavarapu@microsoft.com>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] LDISKFS-fs error: osd_iget: special inode
 unallocated, Remounting filesystem read-only
Thread-Index: AdoiMyl4aY2IfKFNTIK3sO2x22kTZgAAtXKu
Date: Tue, 28 Nov 2023 20:03:47 +0000
Message-ID: <C7079DEF-B723-485A-BB2D-81887571BC87@whamcloud.com>
References: <CH2PR21MB1495094E10A3B5DAD923431DBCBCA@CH2PR21MB1495.namprd21.prod.outlook.com>
In-Reply-To: <CH2PR21MB1495094E10A3B5DAD923431DBCBCA@CH2PR21MB1495.namprd21.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|CY8PR19MB6962:EE_
x-ms-office365-filtering-correlation-id: a2202d2c-c1cb-4ed5-45dd-08dbf04d21d7
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: G8NFsHd02wYUxU5MUg4MXcoldp/hc5JagNYElVSUutjYeN+G7TU7T+P9yQtWVFcU5rlRF+q1lL5bSHtVYpQL51v7NLCb7hibkw92Pfhn84qu1LDQSmtYADYkQvzDSrA1f89OOlprxqTbdnsN4j4tnFVPvOKqhP6Twg6nKZKUI81d4efsnrtJQFvoFTAz9YX0SpqQlcRWkoF72i4+I9ajIEsrV3NVjLwuMyDOtkENDy/qsFFZvEe7bnq8DqtITCr4pJJSttkCrlbVE8l3fmTZZL22LLh6Cw341EJb60STb2ZZI42GC26BUkHo6pkuxe5dFeWk4vyPExYaP0PP3ujENcZorrJvp/fg/j+AO9ROraaVw6VUiO2zATnAfcoz4xJmttq54quGQIF781Sk/cEkAYOFHZJqsw5//ZPjusBNmO7TGFjge7wC+lIzEh4/HFsg3igfcNFDzj6TUrf3WH+pe6AcZdcydIvMnm5Aygejb8LiNRnGGotJwwg+CJEm80NQWWLg5FZfnbkBcfDISd4M4JcsbId627VlLtOP3e0xg78OXM81568zsbjt2pVlSLmZeCflvXtWdt3yZcVTene3Hli90616MDnolhoaaOOSfK4pBj8MJPYEAJg76h9idIwyAZ+fz+S0490iVRi+Y7umIAL067ylWM2I5fSrTh0FwDs=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230031)(39850400004)(396003)(346002)(366004)(136003)(376002)(230922051799003)(451199024)(186009)(64100799003)(1800799012)(66946007)(66899024)(66556008)(76116006)(66446008)(66476007)(64756008)(316002)(6916009)(6512007)(122000001)(36756003)(53546011)(2616005)(71200400001)(6486002)(83380400001)(6506007)(966005)(38100700002)(478600001)(33656002)(86362001)(26005)(38070700009)(2906002)(5660300002)(8676002)(4326008)(8936002)(41300700001)(13693001)(45980500001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?WS80UWF4SUNlaTA5NTduOU5ITy8wM29hZUt4TnVDSnF3ajhFUmE4eUtIL2M3?=
 =?utf-8?B?SitEQWVnaDVnMkFiNEdRd3RWSnBnZm1RN0Z3UzlkZVRnSGVJem9HTkZJRVlv?=
 =?utf-8?B?UWk2RG1FZHAzam16UHlvV3hYVUxVV0VzQ3pQYlBIck82R0Z3MDh3OU01b0hC?=
 =?utf-8?B?RW9pZExZWlhKQTJheEFKR00xMTl4eXo0SzVodXJjNzUybk9YY3VoYnFQa2lI?=
 =?utf-8?B?SVlabVZvT0svU3AycHhGL3owTmZGKy8zUHhBcXBDQ2s3dkkwYlkvQ0VMeURt?=
 =?utf-8?B?RCtLQ21ESjlZWFViUkhGWWpUeXZ4ZEZtUXRUWWdaMXUyQm5XNW54cjlXVGhU?=
 =?utf-8?B?QnhmbncvRHZZZ1M4eWVwaENBQXl6SWJheDRHOWcyNUdIZ3Qrb0tCNFhCN3Rp?=
 =?utf-8?B?bzV0VTlDZEhyUThUdEJUUHJ0L2VhQnEyNjNQY3Rpcmc3SnFvSlBPczgwaVBy?=
 =?utf-8?B?NVFmQW51eU1JVmRNYWx3ZWlkWVgya09HSXZ2a3lNUG9PeXdTeUx6amxMVUNs?=
 =?utf-8?B?ZkhKbzE3MWFveU1Ld1I3b2lQa04xZ0dxZ1ZLL2hWTDBCaWVQWVcyS1VjL1I5?=
 =?utf-8?B?NEl1TWJaTm5ocTlXNGw1bnJrbmZxdWNtdEYzRVFqbDcrMTBGTy9NTHM0dEJr?=
 =?utf-8?B?MzdkM1N4RUhSemFlMVFLUmUwSjRreFlhSDFYMEhkT3Zndlo1Nlo4NlBtamR2?=
 =?utf-8?B?ZzVMWnloS2FtSDQ1T3pyVkNTS2ovVCtDZ2k1eDFNOFRIWUlNZDZ2dklXeGNS?=
 =?utf-8?B?aXNyM2pPYWpEczc1UCtWVjVEODFvOTNRaTRpK25hWHVCZDdPWWlhMjU3Z0Vs?=
 =?utf-8?B?SEh4azh4MExibmsrdCsvYml1THF2UFRRZVNBZFBJYXluK1V0ZGwyYXJOWTR6?=
 =?utf-8?B?bmV5UFYyeE4zbThaMG9oZzNUMk4rcVpuT0V0STZOUFZHNnQ5dXRucVVCUTVn?=
 =?utf-8?B?SkI3V2dmZW95NURwNXpwTkJac2tNdFVIdXBaS1k2Wnc1ZjNXN3k3VVhlc0tt?=
 =?utf-8?B?WnJnNUVhWVZJaWRmMHBEbllUcGY5QWdidzNJMUh6YjA5U2hXVjlWdFJhdFBi?=
 =?utf-8?B?UE96ODY4ZmFvcGxZNXJDL2RhVCtBTWFGOXo2eTQ0QzgyZnhNeDlreUFnQVBW?=
 =?utf-8?B?dTUzVVJwRlByLzQ1M1EzZnVjOWdsYVBhWWpzY0doL0ZtZGVpZzNwTEt4ZFR4?=
 =?utf-8?B?SlZtOWNoWkozb20rRllkWEFuNGFaaFUwZzZkOEJnVUZKaUdBejdzWnNJc1g0?=
 =?utf-8?B?aFRtZFE2bkhUbDJoL1lkcGNKV0R6bkovQzlYMGRyMEhiM3hSVHZaM05ISll2?=
 =?utf-8?B?enJuZThTeklCekI5VW02ekpoSjIwbUxmM0U4R3dWVFpidTFOdEFyS2h6cWla?=
 =?utf-8?B?aXBpc0FXVFg5eExJUlcrY3BZdmhRMzBZRnFPUFQ2dzYrQ2lxVnlyS2YvcERi?=
 =?utf-8?B?T21PeFB2c2dTNFkyOEI0Y1ptbm4yRmxuaUUvN0lqYUJUZm1VWUFoVjd5VjYx?=
 =?utf-8?B?N3ByZmVlSnFwR0U0cGlCR25JcmIxU2tkeXhTb3pRdVdsaCt4VXdJdGkyRzNY?=
 =?utf-8?B?VDdNNjFTUHNRbC9saVZQVXRWRUcySURNdjJvWDJjQlQ3cGpRNUM0MFM5ZXF6?=
 =?utf-8?B?cUw0M1BCZzZ4N1VaTXliNHZzYlNaNkNYbm92RHRZU0hYS1VhUWJFNmxHRFhY?=
 =?utf-8?B?YmV3V0N1QTM2L2xIS1Fvd28xb2JiZGppeVpLeWpETVZJL3ZQM1hXUzZKVGlr?=
 =?utf-8?B?d29mTitqRDl1MkFTdSt5ekVqaVRjbmY5RTRTNjhFWVpzM2VYOUF6ZjMyaXVq?=
 =?utf-8?B?UnZNVWpPaUxwdG1GNWxVQ0w4WWYrMjhQTUNWVUdkMHNJTkJWVnhJSXlwRGRx?=
 =?utf-8?B?bTY4WFA1ejQ2Mzd6VktkWkJYUG1RM1RRWDA4dEJjS2tMZTlBZ3FvVHZBMGpt?=
 =?utf-8?B?WERtMkJNcUhIUW5DcDg0Tm1GNk5ZZXhKVUFvMmlxbFNnZVpLY21MajBPaHgx?=
 =?utf-8?B?Qk96OVRlelJ5QmhNYnYxWjBNOWI4bFIzTkphbmtvODJvclliRmJ5MUNKdzh3?=
 =?utf-8?B?U0ViTnZIdUcwVnhIZkN3R0djQi9jWFRCL1ZlVUlrN25VbTFaYWtWck02SVdS?=
 =?utf-8?Q?J2/A=3D?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: El5cy8yU3VoBB84VVvmruFLdWjfQkJkyn/HYyEG3eBXzX4ljlyfKeAF5snEyM3/Rm2/UwOfSo/qu3FbNuHNPU5jc3dp+/K4pZ1aXY3MY/83riuET0l7tCI9VegYxMyL9ldwMNjBECjw5cl9Rm1sNEpm6VrV+HLt8Vb/yq4NHD8w9ualhsYmwTlJjP0Q4DgTDrovIzOseVvT+nrYG2N39YjDPZ78o+OWZaZcHw8otnRNuMDexZOjqVNU4lEGu/i94w0QG1Cw0Od7o406rwtOHdEvDMCPizkyOO4GXbY8JsKuJDDEjYP/9IBQdvBn2s4stMnQ5SNYHuowLduIS4apCg3uyumNtpsdPkmP5jszyIm62rgOTCXrfLYMaJ0boFchoJ06qtMkvEpWk8f7q7PyMzjt4VE7fpA/CsXgbkITJ9NbaixBlIaQBpf/eE2TptvhkOuo6WACSXqukCJ1R89wOYGfKz4z2u5nCbfDH9cUT4x9TVCPUiXHdp6e00BHV7wJszfZyyxL82hBQrsum7Pw+banlfCFZ3YkGeH3cm5pEkDForbas54r7uz5WD+ckWgzoURA8QBte+AHpln0n3CiZEQl9o4l/a01VwB5XQj/F6lOdteQJiXqZE68hvZPWSi/YqUVaWRJTSF1lnWrihX1WMk5IRfuxH0VVbdu7dhy9TK8pAj+cjX0bijLxhR7LaFiXAOZSbcvsJBNhDlG5wjZgk/NOUk97Lj8qZVE1qoAww6F60LPZ2r4gzRI0Bhw2UjAlqI+DI22ArWroUqOGUTbe53vLz73S7jQUVFJc3Gj5UYOd1NXWr2buhD0z4xcXHxnGWSAYYhTbiJgf9A9NQtTwUpyoR8t0FN/llecgYdXPvaA=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a2202d2c-c1cb-4ed5-45dd-08dbf04d21d7
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Nov 2023 20:03:47.3851 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: OgZikR/4e8jzDIf0+LYp7t6/n7ljl0KMZPnBRF8r7Hsan+RPcUF3bCnQ4d/mEGw4
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CY8PR19MB6962
X-BESS-ID: 1701201830-102099-12464-8100-1
X-BESS-VER: 2019.1_20231116.1739
X-BESS-Apparent-Source-IP: 104.47.66.41
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVsZGRoZAVgZQ0MDIyMDAINXYLN
 nEMtHUwsTczNIy1TQpyTjZwtDc0tBQqTYWAIFgqBlBAAAA
X-BESS-Outbound-Spam-Score: 0.50
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.252463 [from 
 cloudscan23-84.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.10 BSF_SC0_SA085          META: Custom Rule SA085 
 0.40 BSF_SC0_SA085b         META: Custom Rule SA085b 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.50 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_SC0_SA085, BSF_SC0_SA085b, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] LDISKFS-fs error: osd_iget: special inode
 unallocated, Remounting filesystem read-only
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
From: Andreas Dilger via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Andreas Dilger <adilger@whamcloud.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

SSB3b3VsZCBzdWdnZXN0IHRvIHBhdGNoIHRoZSBleHQ0IGlnZXQoKSB0byBwcmludCB0aGUgcmVx
dWVzdGVkIGlub2RlIG51bWJlciwgYW5kIGx1X29iamVjdF9maW5kX2F0KCkgdG8gcHJpbnQgdGhl
IEZJRC4gDQoNCkkgc3VzcGVjdCB0aGF0IHRoZSBmaXggd291bGQgYmUgdG8gbWFrZSBsdV9vYmpl
Y3RfZmluZF9hdCgpIGp1c3QgaGFuZGxlIHRoZSAtRUZTQ09SUlVQVEVEIGVycm9yIGxpa2UgLUVO
T0VOVCwgYW5kIGNvbnNpZGVyIHRoZSBGSUQgYmFkLg0KDQpUaGUgaWdldCgpIGVycm9yIG5lZWRz
IHRvIGJlIGF2b2lkZWQgYXMgd2VsbCAoaWRlYWxseSB3aXRoIGZsYWdzIGluc3RlYWQgb2YgYSBw
YXRjaCksIHNvIHRoZSBiYWQgaW5vZGUgbG9va3VwIGRvZXNuJ3QgY2F1c2UgdGhlIGZpbGVzeXN0
ZW0gdG8gZ28gcmVhZC1vbmx5LiAgDQoNCkFGQUlLLCB0aGlzIGlzICJsZWdhbCIgZm9yIGtuZnNk
IHRvIGRvIGlub2RlIGxvb2t1cHMgd2l0aCBiYWQgaW5vZGUgbnVtYmVycywgc28gcG9zc2libHkg
d2UgbmVlZCB0byBmaWx0ZXIgInNwZWNpYWwiIGlub2RlIG51bWJlcnMgaW4gb3NkLWxkaXNrZnMs
IGV4Y2VwdCByb290LCB0byBhdm9pZCB0aGUgZXJyb3I/ICBLbm93aW5nIHdoaWNoIGlub2RlIG51
bWJlciBpcyBiZWluZyBhY2Nlc3NlZCB3b3VsZCBoZWxwIGhlcmUuIA0KDQpDaGVlcnMsIEFuZHJl
YXMNCg0KPiBPbiBOb3YgMjgsIDIwMjMsIGF0IDEyOjQ3LCBDeXJ1cyBSYW1hdmFyYXB1IHZpYSBs
dXN0cmUtZGV2ZWwgPGx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnPiB3cm90ZToNCj4gDQo+
IO+7v0hlbGxvLA0KPiANCj4gSSBoYXZlIHJlY2VudGx5IHN0YXJ0ZWQgc2VlaW5nIHNhbml0eS1s
ZnNjayBmYWlsdXJlcyBpbiB0ZXN0cyAxOGcsIDIzYiwgYW5kIDIzYyBvbiBVYnVudHUgMjAuMDQg
NS4xNS4wLTEwNTEtYXp1cmUgZHVlIHRvIHRoZSBNRFQgZmlsZXN5c3RlbSBnb2luZyByZWFkb25s
eSBwcmV2ZW50aW5nIGVpdGhlciB0aGUgc3RhcnQgb2YgTEZTQ0sgb3IgTEZTQ0sgb3BlcmF0aW9u
cy4gSW4gYWxsIGNhc2VzIGxvZ3Mgb24gdGhlIE1EUyBzaG93IHRoZSBmb2xsb3dpbmc6DQo+IA0K
PiBOb3YgMjAgMjA6MDY6NTkgZTcyZjA5MDctNTliYS00ZmZkLTk1MjgtMmUzYWQ0NzA1MGU0LW1k
c21ncy1hMC12bSBrZXJuZWw6IExESVNLRlMtZnMgZXJyb3IgKGRldmljZSBkbS0wKTogb3NkX2ln
ZXQ6NTAwOiBpbm9kZSAjMTk1OiBjb21tIG1kdDAzXzAwMzogaWdldDogc3BlY2lhbCBpbm9kZSB1
bmFsbG9jYXRlZCBOb3YgMjAgMjA6MDY6NTkgZTcyZjA5MDctNTliYS00ZmZkLTk1MjgtMmUzYWQ0
NzA1MGU0LW1kc21ncy1hMC12bSBrZXJuZWw6IEFib3J0aW5nIGpvdXJuYWwgb24gZGV2aWNlIGRt
LTAtOC4NCj4gTm92IDIwIDIwOjA2OjU5IGU3MmYwOTA3LTU5YmEtNGZmZC05NTI4LTJlM2FkNDcw
NTBlNC1tZHNtZ3MtYTAtdm0ga2VybmVsOiBMdXN0cmVFcnJvcjogMjkwMjQ6MDoob3NkX2hhbmRs
ZXIuYzoxNzg3Om9zZF90cmFuc19jb21taXRfY2IoKSkgdHJhbnNhY3Rpb24gQDB4MDAwMDAwMDBh
MmQyNzhhZiBjb21taXQgZXJyb3I6IDIgTm92IDIwIDIwOjA2OjU5IGU3MmYwOTA3LTU5YmEtNGZm
ZC05NTI4LTJlM2FkNDcwNTBlNC1tZHNtZ3MtYTAtdm0ga2VybmVsOiBMRElTS0ZTLWZzIChkbS0w
KTogUmVtb3VudGluZyBmaWxlc3lzdGVtIHJlYWQtb25seQ0KPiANCj4gTEZTQ0sgb3BlcmF0aW9u
cyBpZiB0aGV5IHN0YXJ0IHdpbGwgZmFpbCB3aXRoIGVycm9yIGNvZGUgMTE3IChFRlNDT1JSVVBU
RUQpOg0KPiANCj4gMDAwMDAwMjA6MDAwMDAwMDE6OC4wOjE3MDAxNjYzMjIuNjYwNTQwOjA6NDMy
MTI6MDoobHVfb2JqZWN0LmM6OTA4Omx1X29iamVjdF9maW5kX2F0KCkpIFByb2Nlc3MgbGVhdmlu
ZyAocmM9MTg0NDY3NDQwNzM3MDk1NTE0OTkgOiAtMTE3IDogZmZmZmZmZmZmZmZmZmY4YikNCj4g
MDAxMDAwMDA6MDAwMDAwMDE6OC4wOjE3MDAxNjYzMjIuNjYwNTQxOjA6NDMyMTI6MDoobGZzY2tf
bGF5b3V0LmM6MzI0MTpsZnNja19sYXlvdXRfc2Nhbl9vcnBoYW5fb25lKCkpIFByb2Nlc3MgbGVh
dmluZyB2aWEgb3V0IChyYz0xODQ0Njc0NDA3MzcwOTU1MTQ5OSA6IC0xMTcgOiAweGZmZmZmZmZm
ZmZmZmZmOGIpDQo+IA0KPiBJbiBib3RoIGNhc2VzLCB0aGUgZXJyb3IgY29tZXMgZnJvbSBhbiBs
ZGlza2ZzX2lnZXQgb3BlcmF0aW9uIHdoaWNoIHBhc3NlcyB0aGUgTERJU0tGU19JR0VUX1NQRUNJ
QUwgZmxhZyB0byBfX2V4dDRfaWdldC4gQSByZWNlbnQgZXh0NCBwYXRjaCBzdGFydGVkIGNoZWNr
aW5nIGZvciB0aGlzIGZsYWcgYW5kIHdpbGwgcmV0dXJuIEVGU0NPUlJVUFRFRCBpZiB0aGUgaW5v
ZGUgaXMgdW5hbGxvY2F0ZWQgKGh0dHBzOi8vbGttbC5rZXJuZWwub3JnL3N0YWJsZS8yMDIzMDMy
MDE0NTQ1Mi4xNzUxNzczMzFAbGludXhmb3VuZGF0aW9uLm9yZy8gKS4NCj4gDQo+IEFkZGluZyBM
RElTS0ZTX0lHRVRfU1BFQ0lBTCBhbHdheXMgdG8gbGRpc2tmc19pZ2V0IHdhcyBkb25lIGFzIHBh
cnQgb2YgTFUtMTMxNjYgKGh0dHBzOi8vcmV2aWV3LndoYW1jbG91ZC5jb20vYy9mcy9sdXN0cmUt
cmVsZWFzZS8rLzM3NDIxICkgYW5kIGZlZWxzIGJyb2FkIHRvIG1lIGluIHRoZSBjb250ZXh0IG9m
IHRoZSB1cHN0cmVhbSBleHQ0IGNoYW5nZS4gQXQgdGhlIG1vbWVudCBJIGFtIGludmVzdGlnYXRp
bmcgcmVtb3ZpbmcgdGhlIExESVNLRlNfSUdFVF9TUEVDSUFMIGZsYWcgZnJvbSBsZGlza2ZzX2ln
ZXQgdG8gc2VlIGhvdyBpdCBpbXBhY3RzIHRoZSBMRlNDSyB0ZXN0cyBhbmQgdG8gZGV0ZXJtaW5l
IGlmIGEgbW9yZSB0YXJnZXRlZCBjaGFuZ2UgY2FuIGJlIG1hZGUgdG8gc2F0aXNmeSB0aGUgaW50
ZW50IG9mIExVLTEzMTY2Lg0KPiANCj4gQW55IHN1Z2dlc3Rpb25zIG9yIHRob3VnaHRzIG9uIGhv
dyB0byBhcHByb2FjaCB0aGlzIHByb2JsZW0gd291bGQgYmUgZ3JlYXRseSBhcHByZWNpYXRlZC4g
QWRkaXRpb25hbCBsb2dzIG9yIGRlYnVnZ2luZyBpbmZvcm1hdGlvbiBjYW4gYmUgcHJvdmlkZWQg
aWYgbmVlZGVkLg0KPiANCj4gVGhhbmsgeW91IGFuZCBiZXN0LA0KPiBDeXJ1cyBSYW1hdmFyYXB1
DQo+IF9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fDQo+IGx1
c3RyZS1kZXZlbCBtYWlsaW5nIGxpc3QNCj4gbHVzdHJlLWRldmVsQGxpc3RzLmx1c3RyZS5vcmcN
Cj4gaHR0cDovL2xpc3RzLmx1c3RyZS5vcmcvbGlzdGluZm8uY2dpL2x1c3RyZS1kZXZlbC1sdXN0
cmUub3JnDQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwps
dXN0cmUtZGV2ZWwgbWFpbGluZyBsaXN0Cmx1c3RyZS1kZXZlbEBsaXN0cy5sdXN0cmUub3JnCmh0
dHA6Ly9saXN0cy5sdXN0cmUub3JnL2xpc3RpbmZvLmNnaS9sdXN0cmUtZGV2ZWwtbHVzdHJlLm9y
Zwo=
