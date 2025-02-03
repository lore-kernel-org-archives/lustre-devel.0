Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 48974C02192
	for <lustre-devel@archiver.kernel.org>; Mon,  3 Feb 2025 20:25:15 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmyfZ5SkYz1xPj;
	Mon, 03 Feb 2025 12:25:10 -0800 (PST)
Received: from outbound-ip191a.ess.barracuda.com
 (outbound-ip191a.ess.barracuda.com [209.222.82.58])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmyfP6vPNz1wdV
 for <lustre-devel@lists.lustre.org>; Mon, 03 Feb 2025 12:25:01 -0800 (PST)
Received: from NAM11-BN8-obe.outbound.protection.outlook.com
 (mail-bn8nam11lp2177.outbound.protection.outlook.com [104.47.58.177]) by
 mx-outbound40-52.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Mon, 03 Feb 2025 20:24:53 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=OJ4RowIubIp3NXWfdbhVOj6bb+JI47HifEFmxoaOho3xhob+qh3upzWD9CYkWQcWIEGf2RBtpiar2DbAlVqPis6FURrPVukD19Ojv3KQRLgkalQZODhxhdkufIWcYlW5nRFlj5uspAQfr2sYSrpcHrjifDcNvFzYrhWhIK0xOq8YKchHVo7Rt5kMVTpPLWXcTrwB61qqmnBN/76+klAZ30hVNL/24iE4Shl1tO72Bse3Ecy61cywV3Mql8KE/OU4FBSZutgHFErdIvGbEJaEaa1nOK4b2GyxwQAJfrLUjl32OAo2dZDGn+rWqnOqW/O8wJ1tgF6kLcjrKQ9a4PM4Fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=s2RfJe/lAMkICjvNty5CxlQ7qKuTJeZ7j43hMNlZ3s0=;
 b=AJbobj/oEQW0cGJYedq633S8sIZK0A12iFXgQ5YoABYyiTcjyy+5UxzU2Dun63E2NzQPxf27aOG+CymcxKbrTioMzIMSjP6NaVaT4kIQRCCxALPDsCXI5sFozB8YsU2AfI091vovFE5HBltbwCjvNYda52ChFLKj9LnLSKlsU0SnATcx5w6SPP/buMt2LZ+DIKbN9z+4ZNkIU12i6RL+CeLzIp4FzuHgo54+lxNbuoLizXQwG4nnBQ9yN2QvWNyXX8vzqUekwpUtZ0hV0anH9/THZBEq0gW2SaeB1YXtcAVEtVMj97NNusCOxqcMR0GzBhYjIu3d4q8qn5eJQJpGEg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=s2RfJe/lAMkICjvNty5CxlQ7qKuTJeZ7j43hMNlZ3s0=;
 b=uT/Btze1c6my1aAmXznUGsa7lgM06QyArAb/LF83Tg17mxvaV3LSKpsHCbJqBgQ6K995dJEQ6lLfzZqiJXnqTncG7vl+hil7QssbiZ7fDKPQBQP+tese9qCtpxevEZlrA0MZX7AZcad6qc4C2IrC08LFlJYYczCL+RP0gyVNI50=
Received: from SN7PR19MB6567.namprd19.prod.outlook.com (2603:10b6:806:26d::11)
 by SA1PR19MB8928.namprd19.prod.outlook.com (2603:10b6:806:469::16)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8398.25; Mon, 3 Feb
 2025 20:24:50 +0000
Received: from SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04]) by SN7PR19MB6567.namprd19.prod.outlook.com
 ([fe80::db50:586b:7dda:cf04%3]) with mapi id 15.20.8398.020; Mon, 3 Feb 2025
 20:24:50 +0000
From: Oleg Drokin <green@whamcloud.com>
To: "timday@amazon.com" <timday@amazon.com>, "neilb@suse.de" <neilb@suse.de>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Thread-Index: AQHbaF06daQEbe3e/kelMir67rT0hbMbs8GAgAAqWwCAAUdfgIABebkAgAf62QCAAH1kAIAMBm2AgAASkoCAAr/pAIAAJnkAgAAH54CAAAPkgA==
Date: Mon, 3 Feb 2025 20:24:50 +0000
Message-ID: <3285ff88995a57ec6c01917c608519c5a7d0f78c.camel@whamcloud.com>
References: <d008c14bba74e39999ae70af871740a5d0c5c6eb.camel@whamcloud.com>
 <173844834301.22054.134358817491003595@noble.neil.brown.name>
 <82e4528eb0f4961bdc6b065dfcabea03c1a9face.camel@whamcloud.com>
 <AFA09EE9-0679-4484-8571-F03F7DEE20EC@amazon.com>
 <3ce0efd54f2bf45e84882de0e1b469caf1f74397.camel@whamcloud.com>
 <6F2B1870-F031-429B-8257-730845B6E18F@amazon.com>
In-Reply-To: <6F2B1870-F031-429B-8257-730845B6E18F@amazon.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SN7PR19MB6567:EE_|SA1PR19MB8928:EE_
x-ms-office365-filtering-correlation-id: abbeb960-d1e6-465b-d303-08dd4490cfb5
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0; ARA:13230040|366016|1800799024|376014|38070700018;
x-microsoft-antispam-message-info: =?utf-8?B?NWQwdFd1Lzl3anMrdTdGUW1ldGIvbjg5Y2trdXRzdk5DQ2U4ZkFKYXBURitL?=
 =?utf-8?B?aEtvdUovc1lPcVI4MFY2S3luQXdheUNXNlFsQVRaOWxJaFlqMFhlWm5GbC9O?=
 =?utf-8?B?di9mQ2YrM3NFWkhnVm1zMC9oRmdjdE5lOFFocWRjOElBMXdHUVpGcTg1ekdl?=
 =?utf-8?B?TlQrR1M4RUNVVmNOdEJNS0VJV0trbHlvOS8ydmRjVkpLUGZtSEhoYy8zVGNJ?=
 =?utf-8?B?TEhqbHA3ZllPQVVzTytEQW5RVVpTd0gxWEpjMWxPZkRpaEJEbG5iYzQxTE1p?=
 =?utf-8?B?anU4VkJxUXVKN3RIWHE0OGdoNlhRVzVEUEMwWEhCR1RSRkx3eThRMG93em81?=
 =?utf-8?B?Szlmci9hc3lGbnpoWC95Z2RsbVdIUTFrNGJkWTNqQVNjQUhPQmJ1YmVHSjFm?=
 =?utf-8?B?aXBEMU9aQk1Bb09KVll2aUI1cklhcHg2Y2FYSC9HTWZ4OVVWRGlZRWoyRUFS?=
 =?utf-8?B?NmtqNjJYMmVEZnp2bXU5cUdabS9NakE4eGN6OVdmMmRDYjhrMWpEWFJObnkr?=
 =?utf-8?B?bHp2YkNYV1cxZnFiaXFRUkNQR0l1NUJ0ZWI1aTI0VzNHN3NrZEVHNWszZGsw?=
 =?utf-8?B?V1ZjWHFYTVlhczJibTZuYThQYkxOc1V6ZWtTUDZCcVRqRjJLdXc1OHIxV0pZ?=
 =?utf-8?B?RGNFaDdoTDQxNHJLcnRIbi9ZbVpBTmdkUkdRSWRKRW9zd0xjN1MxbGJ1VzF0?=
 =?utf-8?B?MGYvVnlGU2RPeC9VaisveVVoWExjaDFKSllrT0VZSW9ETkhTdlkwYVQ2U0NV?=
 =?utf-8?B?MDZKUThYYU5aK2w1Z1gwVTlucW83VXJXYWF6TEVzOURmcnFlTzk5M1dFRFV0?=
 =?utf-8?B?VkkrSm4zUWRXM1NDbGIzNE5XSFlTblJqb2V0RE5XSUZMMzI1cTREOVBkTEI3?=
 =?utf-8?B?c1pzVkpXV0F3TVVUVWFPdVF2SG9FbnNaVGpDNTJBQ3ZMSDBCekNxbGRRd2NM?=
 =?utf-8?B?M0tpdTBaWEhCWTZwZ3QzYlUzVzkxTUJWZE5lZ2lPZ202amJtWFRxUStzcVI2?=
 =?utf-8?B?MzhJeDI0eVgwbGtkaEZtN3lvY1h3Sk1tQnZaNUNVT3ZwaTN6ZTl5aFdKajRQ?=
 =?utf-8?B?UU9DVnE1bW1BUG1YZTlUL2RnR2xtNlJMZjNYVzloTkIzSWRxNis4UjZqWGRv?=
 =?utf-8?B?S2ZNZ0NseWcxbmIvNmViM1BmUTUwZXZNcmxVQU5idmw1Qkwwbk8yaThEbjU3?=
 =?utf-8?B?eTA5ekN0UHVlbHZsc2NQNDBKRzB5NE9pQXRWRFRzQW8rMlpaWVdlVVZKOThz?=
 =?utf-8?B?SkdoaUNaK1JwOEZjUzc1dVRZL3VNbFpZN3k3MGVwVHhLK01wYkt0WERzTWEw?=
 =?utf-8?B?eEpMcDk2WFM4UmxSWnNrY1JVaDEwemVKbGk2czFteEJSZjVvcFV1UXRZMDk2?=
 =?utf-8?B?RXFOMEUvM285clBaaDh1Ykw0T2xhOWxPY1RPUmVzVGtlbnlWVjJzOUpKQ1lC?=
 =?utf-8?B?ZmZvTHJaRTkwaWgvVzQ0NmwzWFUwdXRSV1c5b3A4SG9HcWowelhKemV0QVpS?=
 =?utf-8?B?L21SaHZ2QTJ1UEpEcjZiamRxNWtoRWYvY2NBR2ZKdTdXc1VIZ2ZLTjdtUmp6?=
 =?utf-8?B?V3FkVzN5d1lxamQ5ckM0RGg2NVVqVk56WVBvQVNlVVQ4c2lHMHdINnNySTJC?=
 =?utf-8?B?YUVyTVpSc0dZT1VZUVBnRVh0WXJoUnlVV2cxU2JmZFN3NjRMUnU4TlJQWEwr?=
 =?utf-8?B?T0JTRXhGbzlPY2hDY05ZQlBWeVpFS1lMUjIvWDJTdFdpYjhBaURQMmN3ZHZp?=
 =?utf-8?B?UEloMWlpYXF6ekswOHJEQlJ5RjBGMnhZdTRIQ0s2M1YwbUszSGZYMmp5K2Y1?=
 =?utf-8?B?V1M4VGVQQkdlbVAreVZlWVIvVWw3bStnSlVZWTl3ODVqQXRGK3JIbEI1dGtV?=
 =?utf-8?B?TFVOdytMYng1cXhONjNPSjloaVFPc29mY0xpL2RMbVVqUlFCT0IveldtdU5y?=
 =?utf-8?Q?8YPoX5ajvbSqccmms7aOlbKeO56+3rfN?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SN7PR19MB6567.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(366016)(1800799024)(376014)(38070700018); DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?aEFLWVM1VUJOWEdGRzl4bzBWZXBUOCs3T2Q5NkxKbmtrWHhkTDUrWWxuYlQw?=
 =?utf-8?B?YjZ4N1BiNlFIeHE5KzBPK2JQMEpiQW9iL2ptRGFhWWNzY1dXVVhTS2NYZ2li?=
 =?utf-8?B?OVFRMnRSNlVnZ1ZiSW9lSng3aEZVbVdvMzlvT0RtbStzbFIyMklMRFdyaU9G?=
 =?utf-8?B?bzVLeEE3QkN3ZjNhNEp4TFErQWppM0lCS2gxeG0zRW5RaEVra3RINXlHV0Yv?=
 =?utf-8?B?emxMYlFkKzZkSDU0SzJidlN6QzEyRFYyOFVnMjNHMTNCUDQxUzhlZGxMelRX?=
 =?utf-8?B?VkJsWVRMNjE4bG4yL0o0cXpOOEpZWTZ6emRsZWluUElicHUzdzlEcWRod1p0?=
 =?utf-8?B?dUlRc2JPY0JmaDU3YWxwcTNoNEZQeDB2aE1MRmZFUlNqdXovOVkycENoOENi?=
 =?utf-8?B?OWUvYkVSYWdWVTZCMWtzT3Nua09SWnpvZzZhN01ycmtyOVVHdGhGMGFJMFdZ?=
 =?utf-8?B?QVNHdE51NWZLRU1aaGp4cmdEbGZ1aTlhZUI5cnBvSnhKK2RNOEI0bVBVaElC?=
 =?utf-8?B?MlpqelhUck42MmRUL3Jham13MDgzZGxhd21pYUtIMy9OdHJpb3JUYmZaRU1D?=
 =?utf-8?B?Sk1admh5WjAzSFZ0U0hTcFErenoxdFBrYWIzYys1Z1NFMFJhZDMzZUZDQXdH?=
 =?utf-8?B?b2JsUWNuQXpUZGZESk9HM2hxUnhEOHcxVEVOS3dsSHpzUzBodkhEWTF5SVgz?=
 =?utf-8?B?SWZLUWdXTjhVZkVsMURTY3AzZHdESWFGQjBZUzVFRTdmb2xabTY5L0tjRkJT?=
 =?utf-8?B?ZWs4UCtnSjFuQitFR2VWY2p4akxrOWVndEpIcXpUTksxZk55aXBCdXBoblN0?=
 =?utf-8?B?YVNXVUhZQ1JLSmV4Z0tsL1pFdTRUZlhXUFdFQ3JWZEJQTUgreTdkZWlBS0lL?=
 =?utf-8?B?ZWx2cmVFa25nck1pbWNPT3BWY01YeS9TV2xuTWZVR2pSQURuSFJCeFJxN3VM?=
 =?utf-8?B?NTU2ek9FNlFQMGV4bGdjK2NVQTY5MkxrWXVUQnVXdjRveDJJWGtxQk9RZmwv?=
 =?utf-8?B?T2FSNmVGQ2ZKOFRBN2Qwd2JwWWhDbGZTQkxTa3c5NHFkOU9OazNCaS91c3RU?=
 =?utf-8?B?b3lSNEF1OVVkL3lrWitRSnpxSjFsNkNKV1c5elUzS3FHUnpOOE1sdWlJSFVJ?=
 =?utf-8?B?c2luaTZKMkh4blliaVhpbDlVY2JiWmNCYTJZdE55SjVJQjFpQ1krR2o4cVpz?=
 =?utf-8?B?K2JkNFNQTW0rVWRmeXJBU0wxRWVabVFRRGFaYjlzNlhJMGZSNXdzY3NNNFVP?=
 =?utf-8?B?eFdlSUdSSDhzK0JieWt4bGRoa1FpMDhZSnh2RzcxaDV4RHhoMzI2cnBLOHRB?=
 =?utf-8?B?b1U2VHQ4L1MyM295QXA4QndFbmFmTkJzVmF6VjBVY0FIdGNOR1A5OEFvZ3Q3?=
 =?utf-8?B?dUs1d0RCOXlYbHVzdVlXRS9ZS3dWQkdleGN6VUVLWDA4Nnk3T0dMZ2dRK3VX?=
 =?utf-8?B?SEFaVnVCcCs0cDhSeEg0QTNIV2xDUndNcDd3bmxkUnpBa2VqdDJ0RHNDR0Mz?=
 =?utf-8?B?Zm8rYVdKaGVrOVhmQUMxQmZzQTh0cHdzcFVnQmdjVTgzVno0bGg0VERVRXpt?=
 =?utf-8?B?OWxZbWt5UFpRRHV2RXdyTHJ3WU1UQzhRM2kxWWtoODR0a243enlvZ2JGMVcr?=
 =?utf-8?B?bTRzWENQYkc0SlA1NG52WVNlRElGbXVsVS9IT0hnelpJcWJEc3ViNnluMW9q?=
 =?utf-8?B?bU9rQ3ZLNCtwWHM2ai80eFhWSEpLZ3lwTUQwOFluMWE5UzQ3UmxHTXNBRnlm?=
 =?utf-8?B?WmhPQUlZSkhvckZWWnNMTXUzNmsyRWkyeTFEbGpMNlM2VzkvTEZsZXk1cGxH?=
 =?utf-8?B?RHBSdW9ycFRIMWh5clVCa2JMOUx0ZkJkdzdrY3dTRlA2Rm15bEF0T0tvQjFF?=
 =?utf-8?B?Z09KSzdraHRmek5ZT1d4WVA2OEM3c1FQek8vcEJVRU5NTHNwM3RUWmdvT0d1?=
 =?utf-8?B?RzdiV1VQUVMyUTBXS1lacGlpRGZEei85cm1ybTVaUGppMTMzWHQzT2w3cHJx?=
 =?utf-8?B?T2xmeWkyYlJvOEFmZm0rY244c09heFVUVE4wYnpIVDNTc2d5ZGtpTU9LTTRI?=
 =?utf-8?B?TnhIeGEvdHVLNXFSRjZrWnVtQnJKUEQzcUNvaFkvbHEveXBCTEJVT25IKy9t?=
 =?utf-8?Q?3MRbRc2w7Vr0kHxS0jx90oTRl?=
Content-ID: <E0B834407DD54246A2349347B3A7C574@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: 0OiXX32qXM0k/dF3NBcllYPnKSiMmJ6+XL3P4W4QqHG0lGjXwG8bpuzKs/822DO4xiYL6mAn6xNg5aqsegtxl9y7syDCflzLJOKOqKwRuZgzEt58jAcbjMBKXY6X5/opcd+owD1PxaNBoKWh+3qJuC3c4opkcNfOqxk0ue3FiV3XUZ4ZhHj3MmlbY3m3TVgZJ5mW+BlsRY/0dFNED1Ez/+KfLtX3EypX0sIOMPI3mM/g0uTxPeoWhpU8I6aK8dtGi1bKAVGx4tfbvmepcmpzWa0qYq8ZOpjOnLynZMrzqYfu5ST6hTlpuphJzttUiXRrjAhPRK6YQm3O3xVa4Pjl/neaYJJjIgdOK2rEW5lqiUtwK/b08KAzBsMGiZyrHS3lDGIHtIqHOZ5F3cy3X6+QYODLcd3DaK94WiuPkO3V4l/fVDdWeIGApBTSq2TYfqDSTNTqGMYmBO2NhpUZH/HWxX0u4fiXANeuG8FQKz6VZQkiuoEDHOGksClKPhuPnSXwAq+36UKLYlVdKwETA7+a0bYnRTwoiCJZRB5hw3Xp29xCmXCRHD7BouzWiGzynTenio2tYSy6gyP6mhZPKit4BAkHaomG2L4RW6L6idsNtVVKZiBYzqWlUHmBCOuGC97tTZviz01xap6aHYDPKSe70Vj9M4R6o4WMA46ydQcL+2A=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SN7PR19MB6567.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: abbeb960-d1e6-465b-d303-08dd4490cfb5
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Feb 2025 20:24:50.6990 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 45D0NIU+Ot0V8+buENRHlRBiCExn7fKkb2iQqVRYLZI+2XX/449XfkpmQ22CqD/K
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA1PR19MB8928
X-BESS-ID: 1738614293-110292-8351-19892-1
X-BESS-VER: 2019.1_20250123.1616
X-BESS-Apparent-Source-IP: 104.47.58.177
X-BESS-Parts: H4sIAAAAAAACA4uuVkqtKFGyUioBkjpK+cVKVoaWRuZAVgZQ0NDY3CzFONUoLT
 k10dLE0NAkzdA40dIAKGiRkpKYZKpUGwsAT2b+K0EAAAA=
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.262267 [from 
 cloudscan21-25.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: Re: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

On Mon, 2025-02-03 at 20:10 +0000, Day, Timothy wrote:
> > Unfortunately cloud is not very conductive to the way boilpot
> > operates,
> > the whole idea is to instantiate a gazillion of virtual machines
> > that
> > are run on a single physical host to overcommit the cpu (a lot!)
> > 
> > so I have this 2T RAM AMD box and I instantiate 240 virtual
> > machines on
> > it, each gets 15G RAM and 15 CPU cores (this is the important part,
> > if
> > you do not have cpu overcommit, nothing works)
> 
> You can do a similar thing in the cloud with bare metal instances.
> Normally,
> you can't do nested virtualization (i.e. QEMU/KVM inside EC2). But a
> bare
> metal instance avoids that issue. That's how I run ktest [1], which
> uses
> QEMU/KVM. Something like m7a.metal-48xl has 192 CPU and 768G of
> memory, so similar to the size you mention. What ratio of overcommit
> do you have? For RAM, it seems to be 2:1. What about for CPU?

don't really need memory overcommit (in fact it's somewhat
counterproductive), but since VMs typically don't use all RAM I wing it
and run somewhat more VMs than what memory permits.

as for CPU - the more overcommit is the better (my box has 96 cores).

if this is to be deployed in the cloud at will, some robust
orchestration is needed host-side - I create 240 libvirt driven VMs
with their own storage in LVM, dhcp-driven autoconf, nfs export host-
side with the right distro - just once per box lifetime and compiled
lustre every time I run testing (so a resh checkout of master-next
usually).
Then configure crashdumping and an inotifywatch-based script to catch
cores and do some light processign and ship results to the central data
collector. (might be more efficient to do using in-vm crashdumping
instead?)

at $11/hour the m7a.metal-48xl would take $264 to run for just one day,
a week is an eye-watering $1848, so running this for every patch is not
super economical I'd say.
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
