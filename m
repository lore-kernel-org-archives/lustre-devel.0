Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 72C31C77B7C
	for <lustre-devel@archiver.kernel.org>; Wed, 25 Jun 2025 23:05:08 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4bSHSV6s5gz20dv;
	Wed, 25 Jun 2025 16:04:10 -0700 (PDT)
Received: from outbound-ip191a.ess.barracuda.com
 (outbound-ip191a.ess.barracuda.com [209.222.82.58])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4bSHS81Pqyz20dj
 for <lustre-devel@lists.lustre.org>; Wed, 25 Jun 2025 16:03:52 -0700 (PDT)
Received: from NAM12-MW2-obe.outbound.protection.outlook.com
 (mail-mw2nam12on2098.outbound.protection.outlook.com [40.107.244.98]) by
 mx-outbound9-17.us-east-2a.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Wed, 25 Jun 2025 23:03:31 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=f+FSd08TeAE3N0/t4us4KtH1oTnGxZ8Iu8RM7d8lLyCyjY5j01zAApsVy5oP4PB8qvgZA/f9GrU3L+jeinTt0VnRR+Y0hzFrq5csiHoUCoHZw7thiJSgQnzICArPa34FBMlNFKhJoSBf0cVhUZ7L9K3h9VNZS725t/OLoFr5paIXaxjBhx7QHJXjq0pJ/rBR96ekKOcaeTHdJCdnLQandXA+U4kuafXKKazDDI3X9kMHMp1hkycnlvhc6ktFNitGEZF0flHIKjWft8RNf/pJFvhjnxCn5DXP1uy2qZ22Cqo3zSPII7EAvdvhxPRQMnJmajgE1mtRGs1adhtIb29m1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=AbK+YgYVHdBn9XNi6hXj9757RU361QZoVHYpmQyi9nA=;
 b=iW/YXU3UryOy8nQO0ds5Bd/R5sn/kqtQRr/1MfesiCKgoXnBFGjP1BtHs4pKCgJocr9bro0FgY6IEUKSceTEQ5FGSb2RFa1MmXquVFttHFVcQVU96AG9qF/nUvyg3mykL+5lim8JF8edz3WKLzbgYaTBkkJHyJJjHJ339+K8MHRkIYms7HwYbX5OGddLlG5eu1huT3kF43SigKWl4BAcVzNsMLQQ3voEuxBceVRP3twTGn6c6rwlTHPC6Nu2SfnL6tFhJ/MH0D2s4TdKN/fIGsGEUlUxoUNydNs0cb7Ov+/atsvS7NotDIZYynz9Z8qGN1FSnBXb5tvjWHBQkI56uQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=ddn.com; dmarc=pass action=none header.from=ddn.com; dkim=pass
 header.d=ddn.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ddn.com; s=selector2; 
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=AbK+YgYVHdBn9XNi6hXj9757RU361QZoVHYpmQyi9nA=;
 b=poHIr9wU281tCh/Y6uuG4oPa3k2bETOpt0BYv6ykn6bdk0tZZZcOhUajFKB/8OssDp2vC3nRbyph3+uiS2NWEz4wiNcoECkKHQFIizVf4AiaeaVnMJWriQ7CXBRfkNi4ZezHxX6+C45qa+0o/ImXQQ2NlxTRu8Gl7FZWsR2+Wtc=
Received: from MW4PR19MB5630.namprd19.prod.outlook.com (2603:10b6:303:189::12)
 by MN0PR19MB6142.namprd19.prod.outlook.com (2603:10b6:208:3ce::8)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8857.21; Wed, 25 Jun
 2025 23:03:27 +0000
Received: from MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::e1df:47f8:9e7b:c4ea]) by MW4PR19MB5630.namprd19.prod.outlook.com
 ([fe80::e1df:47f8:9e7b:c4ea%6]) with mapi id 15.20.8880.015; Wed, 25 Jun 2025
 23:03:27 +0000
From: Andreas Dilger <adilger@ddn.com>
To: Xose Vazquez Perez <xose.vazquez@gmail.com>
Thread-Topic: [lustre-devel] [PATCH 1/2] lustre: refresh FSF licences
Thread-Index: AQHb4h21TfT3xO379kaRHzuNDN0DIbQMO76AgAWrdYCAAHGlAIAACRQAgAHBMACAAAn0AIAARj2AgAATIgA=
Date: Wed, 25 Jun 2025 23:03:27 +0000
Message-ID: <6AEFD371-1A4F-4664-880B-0AF5F71903D6@ddn.com>
References: <cf9555b4-53e2-440b-bffb-19a877783e64@gmail.com>
In-Reply-To: <cf9555b4-53e2-440b-bffb-19a877783e64@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=ddn.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: MW4PR19MB5630:EE_|MN0PR19MB6142:EE_
x-ms-office365-filtering-correlation-id: 5f29cd58-5a8b-41df-b056-08ddb43c7ea6
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|1800799024|376014|366016|13003099007|38070700018; 
x-microsoft-antispam-message-info: =?utf-8?B?Zm9od3Btd0x6K2ZDdTVlaGZVSCtkTXNaa3lHTHVUaVhzaFdXZ2tNbnNzTTM0?=
 =?utf-8?B?SkFvTU4xZExSdDRLUlNOcGxjYkVMYUZWbEpFSHh4V2oyQnRQcmZvZDdobzd3?=
 =?utf-8?B?UTdIUTZvRWJSaUZ2M2RQWWoySjIzV012SzJCUlkxYlBPemZhVGw2YjNOZFBq?=
 =?utf-8?B?WXkzQkZldVdoUjRnbXRMMmhUaWhuZVVTSWJxVU5qVEl5NGJRTXc4YnRDaUtY?=
 =?utf-8?B?VmVET1RTeFk2VGQrM0UxVElMQ2oyRVNJSXZIWHpkSC9iSFJ6ZVpVNS8vSmVJ?=
 =?utf-8?B?RlM4MGY3ZnA1SFM5SmR1K0doR3MrVkVHbTdkOE0xRG1WTFJydVo5MThkV0pX?=
 =?utf-8?B?M3VDVXVWQ0VOWU5uRm4vZllySkdDMWwzZE9NTFlQVlVXS3ZTdGdMTmVnTVc5?=
 =?utf-8?B?NUYvaGFrV1d5VE9tZFlHSkc1K3VCSCtka1Uwd05aQzBRWXU1akZyWmI1ekww?=
 =?utf-8?B?ZE1UemJSN3pKLzNkQ3NKTXd0VDdnZ3FtT3B2NUpnNGNXc2IwYXZGWThRck1r?=
 =?utf-8?B?UzFMRmt0b0RRWkd1NWxQb080czEvZ20xWTRUWHBBTUV4bjVzVU5DeHRhbm52?=
 =?utf-8?B?R2NiVFVIamdYc0xQK2JRT3dSNVlMV0hMRXNZNnk3ZGRuZkxGbEZkblVEbWVj?=
 =?utf-8?B?KzJ3bnBjcXk2ZjQxS044WElySkpEZVdmZlM4UzIwaUJ3SnVUODhCd1Y3UXVI?=
 =?utf-8?B?U1ExaTJ0dWcwYjJwZDhUS3JWZzF5QjFFNFJHYTBMMCswVUNnckt6YWtUUlo4?=
 =?utf-8?B?STNid0FhMUIzYjhWcTgyOTl5UjE1VjQ3QzE1MHJvY0d4UGRJb3k4WlkwNmM3?=
 =?utf-8?B?aWdWTjkvdFYxaVlMRkVsUmtST1N3bGZCem1hU3FldmhTYlpmc202YjFpZ2tW?=
 =?utf-8?B?TUc0WUZCR0Uzb2c3VVN5Nk0wN2pCK2N0cWt4OHQ3ME5BaVhaVzliUjlKampC?=
 =?utf-8?B?OWhzdC9yS3dGV0ZTc3JFTXdrY1BPMHhNeU5VRGRSQ0JDTTdNK1I2dWJVYXAy?=
 =?utf-8?B?L3lFcmFNdHd4a1dlRzNJK1I1ZTVxUHA0WHZROGdaSDU5RkV2LytiRGU5cFFx?=
 =?utf-8?B?VkRVWXNlaUd2WFFjcVN1bDBHeHI5ay9ydENGQmxWQjZCKzZQSDVUZHV3TExR?=
 =?utf-8?B?SVJhOXV3YkhyeWRNdldtMnlMZ2FqMUZDTU5kaWFzSml5V2RYNlhGeUh2RTdR?=
 =?utf-8?B?aWs0NnNFOFp4MXJkUE9VKzFIWmlXRnJjODVSV05hTWNsVGd1dHhHSm5vZElR?=
 =?utf-8?B?SmtRK1BoVlJPOTVPMDQxTmw5ZkJEMjI1amdLQmhyMThseGxOZ2RINDdhQ3BV?=
 =?utf-8?B?emVmYWtOYWtFRm8ybGRWWEdzTGJDNWZIa0RRUm5OWW9acDNGdXJmK2xLRjR3?=
 =?utf-8?B?cU9XQWkzNU9iZ3hHREJ3bjZueHlUa0Q0R2JZcGdMZ0JYV0VMdFhTdVBlOFd5?=
 =?utf-8?B?U2thMXA3cXRBMWkxRlB2MkJ3eWdSRUVqQk54QnBJVkt2Y3BuWmNaRVJ3MmZH?=
 =?utf-8?B?NVJpeElsM0xpSlJWT21PdTFZU2R3SXpkcGtGWjBFRkdwM3l4aWFLOEpTdFVZ?=
 =?utf-8?B?NWNYY3pLUkFPTTF2M29aL3JtQzU5TlF5U0NnNzNMelV3WEd1b1J1RkJDQmlK?=
 =?utf-8?B?ejJZdGJKdW0yWW1VU1ltV1JxdEtERFRSZmF0T0d1dzFDTmx5VWYveU1XSkNz?=
 =?utf-8?B?ZDRJRVhuWVQ0eHRtdHFRTnowb0piWWtlZTR4WHF3bmxQQktWU3ZrSi8xMXB5?=
 =?utf-8?B?dkpaRDRYSlRZMFlwdjUrVmFoRnczTGxUV3dLaHFBbGNhZVZuRnFsUGNuVmFr?=
 =?utf-8?B?dVB2QmhkZTB5UDdNRjhrekdDN3FqVkRDSVo0MlZrRXlnRk5MMlQrYTh3Sm1Z?=
 =?utf-8?B?dXJaUCt3aU9lYTNXV2RqbzdaeW5mRzI3dHQyWElQdVVld0NNbnpKRHVCVm85?=
 =?utf-8?Q?VHBe/ZXl0XY=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:MW4PR19MB5630.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(376014)(366016)(13003099007)(38070700018); DIR:OUT;
 SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?T0duWDVZdWpkMWpwYThDcTYyekF5R3NwK3NGcVJRbDd3VlRmOCt3cDh2RnFs?=
 =?utf-8?B?dmtnYVlJbkFqSy9jazZBclRBQUIyeVhheElyS1lObVFISkNmaXAzWHN2dFFT?=
 =?utf-8?B?R1NaSXZkN21kOHBmelZubGZOVklPeDdyYXVxN1VYbU04S1J2R01BcXVTd2xX?=
 =?utf-8?B?OXE1UnhSVmtVSzZBTml5M0JDS09GZEcwL3A0U2RuUG9pUXdDK2d5T3J3VkUw?=
 =?utf-8?B?NVg0TmJTUEYzMysrY2svOGVPSHp1bW5TbjVsT1dpT3Y3V3VmdDBON1NiOXZU?=
 =?utf-8?B?OTJubTA2M2VpT2NkMDNadzZYMC9jdzdUbHd4amlpL2Qvb1VneFVNSFA2U2tm?=
 =?utf-8?B?SkxPekJPY1hudkF6QUw4ZGJnUkxFditpSzJPWXRwSnRDaHRqYWwxSFVjMFNr?=
 =?utf-8?B?SkdHYXZ6M0tabmtqU0hBSzBEWXI0cUFCV3ZIajdRbmZEWEFxR2MvQXY0WjNR?=
 =?utf-8?B?bTBsWTlwcVVDaFJXQm1WWGdoTU5FU0NnWFlMMHJqVENCZVVnc1RyS2sxVVBa?=
 =?utf-8?B?SHo5ZmFsOU1WTlFySVl2UjNYaElvVU9pVnI5UnVZVDBPZlhWbHBSTGpIRVlv?=
 =?utf-8?B?N0pSck1pVjY1aDZEelNHMXBNUEdEcXo4MEZtR1ZqZjMybnArNklTOVNUNGc2?=
 =?utf-8?B?MXQxc1NnemNjaWkyYmRZMlhHd3hLRTBDeWxhdmlKY0t2TFRGWnUvMDBFTG5n?=
 =?utf-8?B?MERvTFREZWU5VEJIYmNVVEliS2hvbGtPSHU0RmhFNFdYMUo5YkZmRVVmc0Nh?=
 =?utf-8?B?MS81Um93aDRFZnJza3g2WjFlSXhDbmxMd3VNNUtVYkZKZ3EvUjFhTXRHSzBH?=
 =?utf-8?B?NUV1RGNuN3paeWRGS1J0dzR2bk5oOEorUTBycGd4QnR4YldxSG56dWxybWhI?=
 =?utf-8?B?WDMxSkp3RE5ZendFMWIxZnIrZ21rbHV4UEhRSW05bFRUbzJBKzBsQnRockVr?=
 =?utf-8?B?QmY1UkUxSE82bmp4UFp6Smx6SmNyWStVWFRDc3dhV0xyTzRjWi9xZFpyOTly?=
 =?utf-8?B?L3lLWlFlRkpCWjIzQ25zRUZsRndIZFpkVnczbm8rRHI1dlY0ZDNucDhyaENs?=
 =?utf-8?B?d1ltRCtKbVhtbzl0NG9pL1M3ZE9VMlJjVDFwdkxMVDBsM0t5RS9BUTBHNTJn?=
 =?utf-8?B?UGRyQkVKb1orMEtpeFpBMVk1NVhIdzJVcTdaaGpDNTRnQUU0dWhtRk5pWXNN?=
 =?utf-8?B?cGNQSkZCV3pYeDVRM3I2Znd5bGw3SkExa1ZpMVJOd2ZLS3QvMXVORXhxcXFK?=
 =?utf-8?B?UkxQbG5Nb2RFSDgreFhiczVuN0lGQUNXaFUxSC85aG9BZ01HQU53Ujl2c0s3?=
 =?utf-8?B?Q0lMbjl1VG1QMVBPd0hoRFRpaGFlSDc3M2F5cXJPYkdpc2x0SEpQRTNsUkJV?=
 =?utf-8?B?REFWWnNyMFpuRWQ1VnVRaVZ0d0RvaUk4cWNXNFNhcUFBRFlOU09KTVc0RkIr?=
 =?utf-8?B?ODRhTUZaOGpocW5OUXQvUVN5dzFPTXY2K3lYZmNWNlRWak1wQ2wwRUw2NlRn?=
 =?utf-8?B?Tml1c3h1YUlJS2x5NEZGK0Q5SmRBSzFhWk1NRUg2TWpsQlkwUU5LaGdldGpm?=
 =?utf-8?B?MGdDNmwwWnQ1allZbEJYVlViUlpDbHdvRGI1SmYrZFhqSEZzT3JMVzM4Rk5y?=
 =?utf-8?B?YnVySG1zbCt5SHN1YWF2eGF3OHhMSFIrZGF0YUU3M094UkYxS014Rml6a2ZY?=
 =?utf-8?B?YW1mTEZZTnV6NlQxRk93bUpaZmxuTW9DZ1FDQXlhRGxVV3hSSDFjdm5qMHJu?=
 =?utf-8?B?cnYzYkN6cHRaSDE4SWk5MS9IUTNyWHAwYlppOFpEbWhNdURqaHVvVHFpTXFv?=
 =?utf-8?B?ZTkzcHRTa0lBcE9pTWFHVm4zK0hqdDFmQlgzUmtXTzhhZ01EUkRPWUQrQlZ1?=
 =?utf-8?B?WXJUN3ZxbEdYdnZVblFzcXlZemR3dWJ6MTFVckFURE8zaWM4MGt0dFExZHJ2?=
 =?utf-8?B?TGx4d3MrREpKWHlZV3lPTU9XNnJGZXpSWkJvYUxVZ1BqaXkwOTNFNkQ3dk0z?=
 =?utf-8?B?MEo3bWNtK3FxTCtpeXI1WjVGb1MvVkVFUk9Ea1l4cGxJVWdoRURoQlRadVdy?=
 =?utf-8?B?bTJvQnppTUxnb1NKVlU3ZDk4cFhXalgxU1VNd0RSRUQvdHQvcWRlRlVvNVVK?=
 =?utf-8?Q?Je40=3D?=
Content-ID: <7417596C3C917A4DB53C82A7168FE067@teamddn.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: nwtRT0cx1JS3A6o40j4mLeL1n6z4LuIxVqH7VuVov0ZR10SylJ24ICog4L20YqB5kjJuF7MWoosj+8uq4whqJDK9mGelhwdovG3DuJ0BJxIP1RMv0EmSYAz8nJWcn3TcKZXr84tgfj4pXoyOhnlBpoDqUgvNSLLjjMaaSNrCqRy3WyXHOV0zrLetnogyw3ejVltwTZgsmfUpefNXix3K/rft1eAVNrC7FnNSFDyO3NMhl3pAnpdv+PECQxiYBUVfP/LWYB35/U0Ro3TiKwvWWp3ioS57wJFbpG2YfkhNqk1iYL2EunPHxTGowtS1BW6iN+zxwGioJgsdKvL0xNFjMyUHRlpBzbkoRpslwWIczW2Ktmr1ZZ7urkpiD1fHnahGOOwq5+7HRcZp5KHlj5abqgB9hbGbHE8KD6Lb5N85hs8DAUTf3rQX0a1wGR6e8ApdahTFK6H048LejNQkwQO0krgyb7U+GD0/lSHy9V4XUN//rPIkH5zuk0uZgzayzCZZjILTolqRT6HU/06Av4hLaa6GceS4VJbGrNWg0VkWsqmCCEWCtXCPBmuJKXBI5TBLt1H6SPW/60aV4FrDKCEfG8ceDKCd4cyn1t5akqgq7U+Y6s0FnsYuCZWxMvFPit49gBLR4vh4viyHY5q9h45E6Q==
X-OriginatorOrg: ddn.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: MW4PR19MB5630.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5f29cd58-5a8b-41df-b056-08ddb43c7ea6
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Jun 2025 23:03:27.1902 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: VRpl4dJrryUNUkON5JEQyuOkNh+o6aaszC1Hm0H7OTb4YnaEelIfc9q6BSTjuOj7
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN0PR19MB6142
X-BESS-ID: 1750892611-102321-25975-20181-1
X-BESS-VER: 2019.1_20250611.1405
X-BESS-Apparent-Source-IP: 40.107.244.98
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVkamZhZAVgZQMCXJNNnIINnY3M
 zIzDzFxNQi1cLIyMjMzDg5DchJSlGqjQUAgZVW/EEAAAA=
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.265600 [from 
 cloudscan8-224.us-east-2a.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] [PATCH 1/2] lustre: refresh FSF licences
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
Cc: ML LUSTRE DEVEL <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

TXkgcG9saWN5IGlzIHRoYXQgaXQgaXMgdXAgdG8gdGhlIGNvcHlyaWdodCBob2xkZXJzIHRvIHVw
ZGF0ZSB0aGVpciBjb3B5cmlnaHRzLCBzbyBIUEUgc2hvdWxkIHN1Ym1pdCBjaGFuZ2VzIHRvIHRo
ZSBPcmFjbGUvU2VhZ2F0ZS9YeXJhdGV4IG1lc3NhZ2VzLCBpZiB0aGV5IGFyZSBzbyBpbmNsaW5l
ZC4gDQoNCkhvd2V2ZXIsIGl0IGlzbid0IGNsZWFyIGlmIHRoZXJlIHdhcyBjb3B5cmlnaHQgdHJh
bnNmZXIgb2YgdGhlIGNvZGUgYmV0d2VlbiBhbGwgb2YgdGhlc2UgY29tcGFuaWVzLCBzaW5jZSBp
dCBpcyBvcGVuIHNvdXJjZSBhbmQgdGhlIGFzc2lnbm1lbnQgaXMgbm90IHN0cmljdGx5IG5lY2Vz
c2FyeS4gDQoNCkNoZWVycywgQW5kcmVhcw0KDQo+IE9uIEp1biAyNSwgMjAyNSwgYXQgMTU6NTcs
IFhvc2UgVmF6cXVleiBQZXJleiA8eG9zZS52YXpxdWV6QGdtYWlsLmNvbT4gd3JvdGU6DQo+IA0K
PiDvu79bWW91IGRvbid0IG9mdGVuIGdldCBlbWFpbCBmcm9tIHhvc2UudmF6cXVlekBnbWFpbC5j
b20uIExlYXJuIHdoeSB0aGlzIGlzIGltcG9ydGFudCBhdCBodHRwczovL2FrYS5tcy9MZWFybkFi
b3V0U2VuZGVySWRlbnRpZmljYXRpb24gXQ0KPiANCj4gT24gNi8yNS8yNSA3OjQzIFBNLCBEYXks
IFRpbW90aHkgd3JvdGU6DQo+IA0KPiBbQ0MgbHVzdHJlLWRldmVsIG1sXQ0KPiANCj4+IFRoZSBj
aGVja3BhdGNoLnBsIGluIHRoZSBMdXN0cmUgdHJlZSBpcyBmYWlybHkgdXAtdG8tZGF0ZSAoNi4x
My1yYzMpLiBCdXQNCj4+IHRoZXJlJ3MgYW4gZXhjZXB0aW9uIHNwZWNpZmljYWxseSBmb3IgU1BE
WCBjb21tZW50cyBpbiBoZWFkZXJzIFsxXS4gVGhleQ0KPj4gbXVzdCB1c2UgLyogKi8uIFRoZSAv
LyBjb21tZW50cyBhcmUgZmluZSBldmVyeXdoZXJlIGVsc2UuDQo+PiANCj4+IFsxXSBodHRwczov
L3d3dy5rZXJuZWwub3JnL2RvYy9odG1sL25leHQvcHJvY2Vzcy9saWNlbnNlLXJ1bGVzLmh0bWwg
PGh0dHBzOi8vd3d3Lmtlcm5lbC5vcmcvZG9jL2h0bWwvbmV4dC9wcm9jZXNzL2xpY2Vuc2UtcnVs
ZXMuaHRtbD4NCj4gDQo+IFlvdSBhcmUgcmlnaHQuIEFuZCBpdCdzIHdlaXJkLCBiZWNhdXNlIC8v
IGlzIHVzZWQgYnkgc29tZSBrZXJuZWwgaGVhZGVycyAoNTgxKS4NCj4gQnV0IGFueXdheSwgcmVj
aGVja2luZyBpdCwgLyogKi8gaXMgdXNlZCBieSBtb3N0IG9mIHRoZW0gKDIxNTczKS4NCj4gDQo+
IA0KPiBBbm90aGVyIHRvcGljLg0KPiBUaGVzZSBjb3B5cmlnaHQgbm90aWNlcyBhcmUgb3V0ZGF0
ZWQsIGFuZCB0aGV5IGFyZSBjdXJyZW50bHkgbm8gbG9uZ2VyIHZhbGlkOg0KPiBnaXQgZ3JlcCAt
RSAiQ29weXJpZ2h0LiooQ2x1c3RlcnxPcmFjbGV8U3VuKSINCj4gDQo+IEFuZCBtYXliZSBhbHNv
OiBnaXQgZ3JlcCAiQ29weXJpZ2h0LipYeXJhdGV4Ig0KPiBUaGV5IHNob3VsZCBiZSByZXBsYWNl
ZCBieSB0aGUgY3VycmVudCBob2xkZXIsICJTZWFnYXRlIFRlY2hub2xvZ3kgTExDLiINCj4gDQo+
IFRoZSBzYW1lIGZvcjoNCj4gZ2l0IGdyZXAgIkNvcHlyaWdodC4qMjAxLipJbnRlbCIgIy0+ICJE
YXRhRGlyZWN0IE5ldHdvcmtzLCBJbmMuIg0KPiANCj4gU291cmNlczoNCj4gLSAiWHlyYXRleCBB
ZHZhbmNlcyBMdXN0cmXCriBJbml0aWF0aXZlLCBBc3N1bWVzIE93bmVyc2hpcCBvZiBSZWxhdGVk
IEFzc2V0cyINCj4gaHR0cHM6Ly93ZWIuYXJjaGl2ZS5vcmcvd2ViLzIwMTMwMjI0MDYzMTM3L2h0
dHA6Ly93d3cueHlyYXRleC5jb20vbmV3cy9wcmVzcy1yZWxlYXNlcy94eXJhdGV4LWFkdmFuY2Vz
LWx1c3RyZSVDMiVBRS1pbml0aWF0aXZlLWFzc3VtZXMtb3duZXJzaGlwLXJlbGF0ZWQtYXNzZXRz
DQo+IGh0dHBzOi8vd2lraS5sdXN0cmUub3JnL2ltYWdlcy8yLzI1L0xVRzIwMTMtWHlyYXRleF9V
cGRhdGUtS2V2aW5fQ2FuYWR5LnBkZg0KPiANCj4gLSAiU2VhZ2F0ZSBDb21wbGV0ZXMgQWNxdWlz
aXRpb24gb2YgWHlyYXRleCI6DQo+IGh0dHBzOi8vd2ViLmFyY2hpdmUub3JnL3dlYi8yMDE0MDQw
NDEwMzQxNS9odHRwOi8vd3d3LnNlYWdhdGUuY29tL2Fib3V0L25ld3Nyb29tL3ByZXNzLXJlbGVh
c2VzL3NlYWdhdGUtY29tcGxldGVzLWFjcXVpc2l0aW9uLW9mLXh5cmF0ZXgtcHItbWFzdGVyDQo+
IA0KPiAtICJJbnRlbCBDb3Jwb3JhdGlvbiBoYXMgYWNxdWlyZWQgV2hhbWNsb3VkIjoNCj4gaHR0
cHM6Ly93ZWIuYXJjaGl2ZS5vcmcvd2ViLzIwMTIwNzI0MTA1MzIyL2h0dHA6Ly93d3cud2hhbWNs
b3VkLmNvbS9uZXdzL2ludGVsLWNvcnBvcmF0aW9uLWhhcy1hY3F1aXJlZC13aGFtY2xvdWQvDQo+
IA0KPiAtICJTdG9yYWdlIExlYWRlciBERE4gQWNxdWlyZXMgTHVzdHJlIEZpbGUgU3lzdGVtIENh
cGFiaWxpdHkgRnJvbSBJbnRlbCI6DQo+IGh0dHBzOi8vd2ViLmFyY2hpdmUub3JnL3dlYi8yMDIw
MDgxMjEyMzAzMC9odHRwczovL3d3dy5kZG4uY29tL3ByZXNzLXJlbGVhc2VzL3N0b3JhZ2UtbGVh
ZGVyLWRkbi1hY3F1aXJlcy1sdXN0cmUtZmlsZS1zeXN0ZW0tY2FwYWJpbGl0eS1pbnRlbC8NCj4g
DQo+IA0KPiBCVFcsIHRoZXJlIGFyZSBzb21lIG9kZCBjb3B5cmlnaHQgZGF0ZXMgKDIwMjYhISEp
Og0KPiBnaXQgZ3JlcCAtaSAiQ29weXJpZ2h0LioyMDI2LioiDQo+IA0KPiANCj4gVGhhbmtzLg0K
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KbHVzdHJlLWRl
dmVsIG1haWxpbmcgbGlzdApsdXN0cmUtZGV2ZWxAbGlzdHMubHVzdHJlLm9yZwpodHRwOi8vbGlz
dHMubHVzdHJlLm9yZy9saXN0aW5mby5jZ2kvbHVzdHJlLWRldmVsLWx1c3RyZS5vcmcK
