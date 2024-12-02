Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4A7ACD4978D
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Dec 2024 00:04:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Y1kXp6S4jz1x5Q;
	Sun, 01 Dec 2024 16:04:10 -0800 (PST)
Received: from outbound-ip191b.ess.barracuda.com
 (outbound-ip191b.ess.barracuda.com [209.222.82.124])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Y1kXk501tz1wdx; Sun, 01 Dec 2024 16:04:06 -0800 (PST)
Received: from NAM11-CO1-obe.outbound.protection.outlook.com
 (mail-co1nam11lp2168.outbound.protection.outlook.com [104.47.56.168]) by
 mx-outbound-ea46-177.us-east-2c.ess.aws.cudaops.com (version=TLSv1.2
 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
 Mon, 02 Dec 2024 00:03:47 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=b1XO7UPoFxM6fxbEB7XOPpO7cMoDXK85tc0XAK0UKoqa3F1Snmg/s1c4whHJWPTXKg+3aJ/p5vBt6GQBEod65Slc37cJ4V3JAVDU8lWXfC4rIZ98dmKfB+fnZJkBHhIpkyIjEkObmz1EOsnclqClR7wcA0DuBcxDdeuo8EeedEy65fCUtrRDOL+M4Hlli2ifwY1COJzdiGEgZzhCjOLPsMgyyXzGJISR5uvDR/77pOQ6sDC/B3gF/nV4D8agtJtIIPlEHEBynvJ/pUXs4gyS5KXiy7qQWM3b6HA8JjWsxUjciw8DGztBUlTiRL99Zdz8zxwEqIQ6jbfz6ZNZiO8RZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=k83Yc1dQNimjB2hLQ8C6E1I4gMEOhS69Gnp5ur5Avbw=;
 b=P69/h8CoYDo0RIA+3fnJt3QF+QT9aOaQ2rQ223dTR/ixha0S72ZcM4ID8ZLDMqFG4DNrBnvZ1g4bWc3fxPw8DPH3cLoXpJ6/tg8gcK+BFVC2kMwtS2pCK7cfJteDYJgWdh+P2ApvArOekAxfcgiMfjRh4ae5vTMvnC9C64TBOSooIhSfKU7g2kuTCtzbfOY/4aOikF598/wHrEdrm60Rlecu3FOFJuo47vBVRQYfmjYiK5kkfd6gEcQamZ8ulX+7xV7uheFJmTpAJk5y8KljmvQDNzJlQEqvGSdJBcCy6hgzxeO9wvexyOpwAZXEVBLZNrB3JePbINQgUxQH6hIepg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=k83Yc1dQNimjB2hLQ8C6E1I4gMEOhS69Gnp5ur5Avbw=;
 b=K7y4eMrhUfJL9x5jWoYy/ZW16s1OPUBmfCP0SzW7lf078ZLvQ230QCiyWb2/NNeLWEERDLUD2T40hfUPtYpjpaM/mMuSOLTg9YZpq1FeubC/BSKg2hgr/KO1SStfK/76PFujEqkm6DVPaIjCIkXPiYgWbyUogdC0Ka2SIsfv5iM=
Received: from SA1PR19MB7061.namprd19.prod.outlook.com (2603:10b6:806:2be::9)
 by CY8PR19MB7106.namprd19.prod.outlook.com (2603:10b6:930:55::6) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8207.16; Mon, 2 Dec
 2024 00:03:44 +0000
Received: from SA1PR19MB7061.namprd19.prod.outlook.com
 ([fe80::1b3f:9d98:1d8a:3ef6]) by SA1PR19MB7061.namprd19.prod.outlook.com
 ([fe80::1b3f:9d98:1d8a:3ef6%7]) with mapi id 15.20.8207.017; Mon, 2 Dec 2024
 00:03:44 +0000
From: Peter Jones <pjones@whamcloud.com>
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>,
 "lustre-announce@lists.lustre.org" <lustre-announce@lists.lustre.org>,
 "lwg@lists.opensfs.org" <lwg@lists.opensfs.org>, lustre-discuss
 <lustre-discuss-bounces@lists.lustre.org>
Thread-Topic: Lustre 2.15.6 released
Thread-Index: AQHbRE2n6Rpb+ZwYI0e4hs2i4k4gIQ==
Date: Mon, 2 Dec 2024 00:03:44 +0000
Message-ID: <A6A3005C-542A-4061-B179-E83011FA2B45@whamcloud.com>
Accept-Language: en-CA, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Microsoft-MacOutlook/16.91.24111613
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SA1PR19MB7061:EE_|CY8PR19MB7106:EE_
x-ms-office365-filtering-correlation-id: a745e279-483a-4183-be1f-08dd1264c999
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230040|1800799024|10070799003|366016|376014|8096899003|38070700018; 
x-microsoft-antispam-message-info: =?utf-8?B?aklXb3hRRmFNYTk3SDNJaHIwb1VkcFNPdkF1RUxPUTlabElZcmJ0ay91SVNw?=
 =?utf-8?B?WkFiK0hHV3V3b0Y1bzNKYVBWZmtPdXlPTjdqUkNHSWZwYkhxbEs5ZnpvRmpD?=
 =?utf-8?B?dmxTZktUS3RsTHl3amRnTndVSUJqZ2NibWpmeUpKTUdKclJXditSWTlIUDR4?=
 =?utf-8?B?N1hVL3d4UVdTc1VmZ1czaGt5WXFPMERCUXJmV2h4eXIraWVkY0dwc3FhQnA3?=
 =?utf-8?B?OXk5alpUSzNXQU5iVDM4bG5RNHVPUUF2Q3cxMWlHOW5Xelc3aVlJVjlKTUtK?=
 =?utf-8?B?bStucWZBeUdDQXRqbW1UNDBQQnJjM29iNmtsRmtSbERpSnkzcjlPbnpsVm9G?=
 =?utf-8?B?bk54V0ZiQjRwbkdSK3BqZGlQS3YvYkdpU0xKd2hrcU9QWG5XZ0hmQmYwaHBr?=
 =?utf-8?B?MkNLVzhLU3VLbTJ0U3NDYUZrYTNiY2JjMmVzRlR3d1dIaEl3M2RaMTdlUHo3?=
 =?utf-8?B?anVSbHlEZnNoakl1KzFMajhSWnQ0SlpyQnlkeFNkdW5LTzgyOG5uSURUR25Q?=
 =?utf-8?B?MFdRVVFvTHRTalJzVnpYUVFKU09YVEJiendJV01tSWUxVVA2RS90VGNlUEFo?=
 =?utf-8?B?azdUeC9HQ1krRFdSWUt1TDBWcU52VlA3b0F3aW8xUEVBWWVuZHppUlpXWisy?=
 =?utf-8?B?UEtRbzhmT082TVdDM2JEY3kzbkRlREFTOXloV2hkWS9TdWhObTFESGl5dGFY?=
 =?utf-8?B?RHAwWXI3SkZ5UXNnSHIvZ1o3R01HakpPcVVlbmk2aTVudEdKalZWcXZKN0Ir?=
 =?utf-8?B?V25lOXppN2NaYmJycU9QYXVvTzVQZ3N4d3NGVlp4Q1dESUh5TXZvYWYyK01S?=
 =?utf-8?B?SnV0L3M3c1kyVkVUOS9waWxQd2VQTG1rUk4rekZhTmppRUI2citiU0FOc0V5?=
 =?utf-8?B?WUw2R0laWENLdEV6RVI3bTdjbjRMbzBQTzRHVHpFQW5aRzZPUnZVNjVuRXU2?=
 =?utf-8?B?NTBpaCtTN1k3WVhwUU1WdmlnaTN0VmpueXlqYTd6L25PQkpPYmtaNW1QTW5a?=
 =?utf-8?B?aTMrRTZsWkNyTkM0dDFNUGFIOFZOREdWQnlWMWVrU0lORGRiQ3BIM1JLalhz?=
 =?utf-8?B?ZHoyNWZMcjlPdFlqVmkwZXdxSjdySngzVk9nTC82Um9paG9NcU1HTnBiVVV5?=
 =?utf-8?B?V2ZaeUc0Qm5Xck1nNnpqRWRlUmVUenJPK1pxNHhvbXk1Q3Q4QnQxWW1iMnM5?=
 =?utf-8?B?d3YvTzdZYVFUNWltODFEK1psbFh6bzhDc3FjQ0VSNVRGRzZPSTRFZWxCM0hs?=
 =?utf-8?B?VWRIZDdTcmhDNFJxMkFrSndOL0crQk9NQXdxS3I1aEpTNmhJcXU4OEtXU2Z4?=
 =?utf-8?B?ZDJPdDBHUXVHVjRZS0pmL0hRcmhJUHVSbE1jbU01eVVhUng0bk4xRnNZVC82?=
 =?utf-8?B?V25mTmZmbURpVDRsWTE1ZE04WDFxb0ZEM0JkSThlM1VVYm5FamdaTm4rMko2?=
 =?utf-8?B?WWhhb0dHeHB5SHdtbjVJNlJZdGVCOVRlbGg0Z254cDZ3UVVSLzFKV0VaMXJQ?=
 =?utf-8?B?R0g1Tk0xZlZ0eDdyYUtiNXNYRzV0OGNxRThYcm5vRHRuWC9VL2hsNnN1eFRR?=
 =?utf-8?B?Q3ZYZFUzOURBdEgvN0NpV1l1V1NUL09lSGVzUW5hL3NUT3QrVXZMaENvL2cv?=
 =?utf-8?B?Ykc4WERHSmY1c2ViYUtkMEZjZmhhMkdyQXJwVU5uVkRLTGVwOE5GU0YwTk4v?=
 =?utf-8?B?WjR0a2tBOHA3U3MxYXFuSUEzRUU2b0k4TERUdWt2YUNpOVZJdWZNa0orRUlo?=
 =?utf-8?B?V1paUnNtVVBWamxUcUZINGx6cHFlZlpmb2wrQVFpM1M0cmNlY0NRbWcwdWM2?=
 =?utf-8?Q?lR36cXn5l8BmC+lL1XDf29jLf7B9oMS9DyqcY=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SA1PR19MB7061.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230040)(1800799024)(10070799003)(366016)(376014)(8096899003)(38070700018);
 DIR:OUT; SFP:1102; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?QjZ6MExGUGlJTTJDeng3cVJBeGpsblhMblNBNVZ5OGlHTURSWXhNOFhLc00r?=
 =?utf-8?B?bW0xNStNWUxHbHZvYjQ0eUp5YS8vVWlwR09iYWM0eG1mU0trbzkxcE1Uakk2?=
 =?utf-8?B?b1BDZFlpSk5MeVVKSzFYeEkwZ1BBODY5c1lidFNFVmJieHY2bkpHTFp4TGdl?=
 =?utf-8?B?MWVWb3ovQU1jQmNac29ob3k0elorM0lxQUtublM2SFNqZEZCL0h2bGQ4VHU1?=
 =?utf-8?B?MjdZMEVtR1RjRWg1VzFGVU5pOFFOZzBtaDBiV0NZUExUeVNha2NBUEVZdk9h?=
 =?utf-8?B?OWc0UmhYUDk2M0x6b1h3VEdvaUhiRVlNbU5Gd05vajN5d25COTJGeFR2ckpp?=
 =?utf-8?B?MTRrbDNWbU9PcHNsdUVuS1pMSm5iNjBYTUZIS29JSXJjVXJpSXBqTVlLVnRz?=
 =?utf-8?B?REZ2ZW95ZkpsQXlTdmlTRWp5TlFkSlp0YjB0QTA5VnJtVzh1WWFCd0dWTElJ?=
 =?utf-8?B?cS90eEVRNnVuTk96TXdHeEpZZzhTMlgzMy9VWHRCcDYyeFY0ZVh5ZGkyVjhB?=
 =?utf-8?B?VmIraFl3ZjFkdERKeER5QlhvUjRqSmtvNWRyNmdjTVVxSEVCVU9keUhPZ0JG?=
 =?utf-8?B?YUk0S1FoNUhsNnUrcjhqb1dabTZvSnhCQTI4UGNFbS9lNjVqdWI0b2t4b1N0?=
 =?utf-8?B?dnRTOFhFdmtXSjJ4aEs5TWNZRW85Q1MwaE1FMk0vamRzY0pDN29XL3NCVTAr?=
 =?utf-8?B?MW9SaW1TRnJXb25pWUp3VGhaUjFBb1lSNXJZM3F2UURnV0Y2Ti9YQkFDTTZO?=
 =?utf-8?B?Rm52Qkx1QlpxQVJDdDFtWlJmV05DMy9zWWtETm5lek9vMEdyWG12WHB5WUJK?=
 =?utf-8?B?T1pKWmIvUE83N1BNUDNsZTFKU3QzL3JFbTQrS29uTVBGRVZYMWJKUUxhRFBT?=
 =?utf-8?B?VUJ4bTZtZ0x6TmtuelFlVjFUaUZuZ3ZMUEI3Q3pYaDNXQm8vVC9SZWNpQzNC?=
 =?utf-8?B?Y1VrR3I4V1ZKMWJhcjluK3pxOXFhQ2Z5bTNTTUlqRlVzZzY0TS9kY2tQd2cy?=
 =?utf-8?B?KzcxbDg3NUl0OVBOanZ5SzlMM1RMWGpoZXRYU08rT2RnTjkydUZlQWtSWnJ2?=
 =?utf-8?B?dzZaaVBUWk56engxSzFEcngyVWZWUm11UDJwNndna21HdVdpQk1tUkZBRmZk?=
 =?utf-8?B?N0NyeVJBZEZ3M09KZ1FrZndLU1pnM3J5Wnl2b3BWNEg5Q0xzWTR2SFpIdlo2?=
 =?utf-8?B?QXdrQThmWmVZajRzVHlRYVQ0NE55Z25zRUYyYzUyeUdKYkVXb3FjTHBTWDZ0?=
 =?utf-8?B?a2M4OHZHVm9pd25ndk9iTVlHUlEvdDY5eDI5NkVseWQ1WDI0MHhodEhRd0Vq?=
 =?utf-8?B?ejJSd3ExL1BPQk9JODl2VURvUUE3V1B5VWtKVndvZmdoRytQK0hEVG1zZUpH?=
 =?utf-8?B?OXp4YUVCU3lzTzBTTHQxd3FrYS80MWlsRnBiWlE4RzZycWdDVlpiQ3lUVllH?=
 =?utf-8?B?dVZ1NFRNOUFlT2lyb1c3cWQxMko3TGtNdzNMNlVFejZBcXpqdTBLcS9hMUE1?=
 =?utf-8?B?VDNGcllpL3djZ3g2T2ZTMzlVd09tdVQ3Y2hNQm90bzVkU29ZQXU2cU5DdXpS?=
 =?utf-8?B?dFhnbjRDVFhRWGhKS3FmNHZodjArTGR3bGUxazBGTysrL0x2UDJuTmNSdnYz?=
 =?utf-8?B?YmNhckZtbFFETEpKR1ozKzFoVlJoeWlyUFFnWFZoYXBCQVpiV0JicVV4eEo0?=
 =?utf-8?B?TGhIeWowWmJWRVgydFk2cGo4T2c1dGxvcC9XSmphQUd1VnMzOVowRGRMSjZE?=
 =?utf-8?B?MFk3SUhaODhycjNPN3E2Y3JqbG51NURFTGF3R3loaEloQjJVUHlqUFdJb3pJ?=
 =?utf-8?B?SGthTHBRNmlEWDNqYk1GL3pxY0NiQjNQdGVJMkVuM0JqK0tVcy9YSUtzOVds?=
 =?utf-8?B?M0xUa0Q4eTNRTEMvN25ZNFQvL2NhbEs3d2xZbWxuTzFoV1pqRXBGWWhycnFU?=
 =?utf-8?B?MjVubExnSXZ1S1dQaExjZnRBeEdQQ1RwaE1DWFYvdWJWZWNYZm1Fd0k3bmdF?=
 =?utf-8?B?UHhYWkU1aWJTM0RhR2ZwN0RiSXd6M3FLT0liMUI5S0UvMFM5L0NGVGdkYlRR?=
 =?utf-8?B?MSt4Q1grSlEvcmhSTXlEeHhSLzVlQmNmSHd3ZGhVNkMzaEdKVUtvekZEWDhi?=
 =?utf-8?B?M2hEb1dWejhBalBQTTRxZnNVWHJQdGw0ajc4RlFvK1Q2ZzFKdVhsbXI2M2VH?=
 =?utf-8?Q?FkEGxM3SO7lWyQqfQy0AQ3gKSqOW8zyJxY1njYZ38vaJ?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: 7W1y3hf63OS/BO84gaLdBv+fePcH6lDEwfhd94i8zjQIaGkLeWEd7dAoGAUHxWhiv7T40QqFsb6cEd0mwm2DQyi0JtMDzDBg/LU2pWSIjxfwno3C/5VsmRDGl3N2Yez2Cp6GH79JBpgfuYtNeVb0PS1/ukKh4cCH8if/5q7Ys1+NRPJBBQcB9VSfhAcWpqoogI3BBzdxUnbqsQhNJSurASfrtnygd+qR/uTJZ//8EApExSoLjkjvB+WlNpiXl/eRyXEYUZQ99N4i80NwyXKj0Qtkgh36K/Kt5114FXMi5xW+43PIEuDbZzmu/VzkF0LavPPwit6nt2cLr0HdMqCU0DEQuwjiPfP61vTgGUKq1HLFpl70h/qxowVRcVD6cmf38c0gg3vETXm6ubf1aUy/x56Kg8XAqLywYe+mVizgJCoU2nbYtefmADPbI0MOmnh9LyNKnnmH2ROKDR4sTdCX+fgwl0NxDnqwgN8Ii+HkKSbf8Yuqd4kyTT7m6+/WxwI4E2PG0Gz5O3PkcfXKKKvwPRSTdD07Uer3l6vWaeBvpteL74sHg1uQq4bZe+9ni0ht2+38nZbgJksZkM7OfZkIscxNBorjKxZtgGtNhndGpeHXkE4YL8IwrQWGFIF0G8/E7eAFaYuVLp7u8fjrV+Ut6E3WzBBhKiNdzgx3k2odHYM=
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SA1PR19MB7061.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a745e279-483a-4183-be1f-08dd1264c999
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Dec 2024 00:03:44.4529 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: hmsmClzDt+ada9vgxTs91MjDxHQxbYNYm1ZlYV4LWGJUd+mGI/XFpW3tp8f/ZsHl
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CY8PR19MB7106
X-BESS-ID: 1733097826-111953-20759-13434-1
X-BESS-VER: 2019.3_20241126.2120
X-BESS-Apparent-Source-IP: 104.47.56.168
X-BESS-Parts: H4sIAAAAAAACAzXLsQ7DIAyE4XfxnAFs4ExepepAYqwsVYcyVKry7mVIltOvk7
 7Hj/p30Epj7kLvD62KMuOYX2ohGwcIUmdpqdqm4hyNtZaNjc7l5sd4XTwDcnk41wRvXN
 SALB5Mo2Hfu2sJsdP5/AORhAJTgAAAAA==
X-BESS-Outbound-Spam-Score: 0.00
X-BESS-Outbound-Spam-Report: Code version 3.2,
 rules version 3.2.2.260824 [from 
 cloudscan16-103.us-east-2b.ess.aws.cudaops.com]
 Rule breakdown below
 pts rule name              description
 ---- ---------------------- --------------------------------
 0.00 HTML_MESSAGE           BODY: HTML included in message 
 0.00 BSF_BESS_OUTBOUND      META: BESS Outbound 
X-BESS-Outbound-Spam-Status: SCORE=0.00 using account:ESS124931 scores of
 KILL_LEVEL=7.0 tests=HTML_MESSAGE, BSF_BESS_OUTBOUND
X-BESS-BRTS-Status: 1
Subject: [lustre-devel] Lustre 2.15.6 released
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
Content-Type: multipart/mixed; boundary="===============8966364723362533465=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8966364723362533465==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_A6A3005C542A4061B179E83011FA2B45whamcloudcom_"

--_000_A6A3005C542A4061B179E83011FA2B45whamcloudcom_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

V2UgYXJlIHBsZWFzZWQgdG8gYW5ub3VuY2UgdGhhdCB0aGUgTHVzdHJlIDIuMTUuNiBSZWxlYXNl
IGhhcyBiZWVuIGRlY2xhcmVkIEdBIGFuZCBpcyBhdmFpbGFibGUgZm9yIGRvd25sb2FkPGh0dHBz
Oi8vZG93bmxvYWRzLndoYW1jbG91ZC5jb20vcHVibGljL2x1c3RyZS9sdXN0cmUtMi4xNS42Lz4g
PGh0dHBzOi8vZG93bmxvYWRzLmhwZGQuaW50ZWwuY29tL3B1YmxpYy9sdXN0cmUvbHVzdHJlLTIu
MTEuMC8+IC4gWW91IGNhbiBhbHNvIGdyYWIgdGhlIHNvdXJjZSBmcm9tIGdpdDxodHRwczovL2dp
dC53aGFtY2xvdWQuY29tLz9wPWZzL2x1c3RyZS1yZWxlYXNlLmdpdDthPXRhZztoPXJlZnMvdGFn
cy8yLjE1LjY+DQoNCkRldGFpbHMgb2YgY2hhbmdlcyBzaW5jZSAyLjE1LjU8aHR0cHM6Ly93aWtp
Lmx1c3RyZS5vcmcvTHVzdHJlXzIuMTUuNV9DaGFuZ2Vsb2c+IGNhbiBiZSBmb3VuZCBpbiB0aGUg
Mi4xNS42IGNoYW5nZSBsb2cuPGh0dHBzOi8vd2lraS5sdXN0cmUub3JnL0x1c3RyZV8yLjE1LjZf
Q2hhbmdlbG9nPg0KDQpUaGVyZSBhcmUgdGhlIGZvbGxvd2luZyBub3RhYmxlIGVuaGFuY2VtZW50
IG92ZXIgMi4xNS41Og0KDQpSSEVMIDkuNSBpcyBub3cgc3VwcG9ydGVkIGZvciBjbGllbnRzICAg
KExVLTE4Mzg3PGh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29tL2Jyb3dzZS9MVS0xODM4Nz4pDQoN
ClBsZWFzZSBsb2cgYW55IGlzc3VlcyBmb3VuZCBpbiB0aGUgaXNzdWUgdHJhY2tpbmcgc3lzdGVt
PGh0dHBzOi8vamlyYS53aGFtY2xvdWQuY29tLz4uDQoNClRoYW5rcyB0byBhbGwgdGhvc2Ugd2hv
IGhhdmUgY29udHJpYnV0ZWQgdG8gdGhlIGNyZWF0aW9uIG9mIHRoaXMgcmVsZWFzZS4NCg0KVGhl
IG5leHQgTFRTIHJlbGVhc2Ugd2lsbCBiZSAyLjE1LjcNCg0K

--_000_A6A3005C542A4061B179E83011FA2B45whamcloudcom_
Content-Type: text/html; charset="utf-8"
Content-ID: <8C461271A694624083A1911BB7B4C3F7@namprd19.prod.outlook.com>
Content-Transfer-Encoding: base64

PGh0bWwgeG1sbnM6bz0idXJuOnNjaGVtYXMtbWljcm9zb2Z0LWNvbTpvZmZpY2U6b2ZmaWNlIiB4
bWxuczp3PSJ1cm46c2NoZW1hcy1taWNyb3NvZnQtY29tOm9mZmljZTp3b3JkIiB4bWxuczptPSJo
dHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL29mZmljZS8yMDA0LzEyL29tbWwiIHhtbG5zPSJo
dHRwOi8vd3d3LnczLm9yZy9UUi9SRUMtaHRtbDQwIj4NCjxoZWFkPg0KPG1ldGEgaHR0cC1lcXVp
dj0iQ29udGVudC1UeXBlIiBjb250ZW50PSJ0ZXh0L2h0bWw7IGNoYXJzZXQ9dXRmLTgiPg0KPG1l
dGEgbmFtZT0iR2VuZXJhdG9yIiBjb250ZW50PSJNaWNyb3NvZnQgV29yZCAxNSAoZmlsdGVyZWQg
bWVkaXVtKSI+DQo8c3R5bGU+PCEtLQ0KLyogRm9udCBEZWZpbml0aW9ucyAqLw0KQGZvbnQtZmFj
ZQ0KCXtmb250LWZhbWlseToiQ2FtYnJpYSBNYXRoIjsNCglwYW5vc2UtMToyIDQgNSAzIDUgNCA2
IDMgMiA0O30NCkBmb250LWZhY2UNCgl7Zm9udC1mYW1pbHk6Q2FsaWJyaTsNCglwYW5vc2UtMToy
IDE1IDUgMiAyIDIgNCAzIDIgNDt9DQpAZm9udC1mYWNlDQoJe2ZvbnQtZmFtaWx5OkFwdG9zOw0K
CXBhbm9zZS0xOjIgMTEgNiA0IDIgMiAyIDIgMiA0O30NCi8qIFN0eWxlIERlZmluaXRpb25zICov
DQpwLk1zb05vcm1hbCwgbGkuTXNvTm9ybWFsLCBkaXYuTXNvTm9ybWFsDQoJe21hcmdpbjowaW47
DQoJZm9udC1zaXplOjEyLjBwdDsNCglmb250LWZhbWlseToiQ2FsaWJyaSIsc2Fucy1zZXJpZjt9
DQphOmxpbmssIHNwYW4uTXNvSHlwZXJsaW5rDQoJe21zby1zdHlsZS1wcmlvcml0eTo5OTsNCglj
b2xvcjojMDU2M0MxOw0KCXRleHQtZGVjb3JhdGlvbjp1bmRlcmxpbmU7fQ0Kc3Bhbi5hcHBsZS1j
b252ZXJ0ZWQtc3BhY2UNCgl7bXNvLXN0eWxlLW5hbWU6YXBwbGUtY29udmVydGVkLXNwYWNlO30N
Ci5Nc29DaHBEZWZhdWx0DQoJe21zby1zdHlsZS10eXBlOmV4cG9ydC1vbmx5Ow0KCWZvbnQtc2l6
ZToxMC4wcHQ7DQoJbXNvLWxpZ2F0dXJlczpub25lO30NCkBwYWdlIFdvcmRTZWN0aW9uMQ0KCXtz
aXplOjguNWluIDExLjBpbjsNCgltYXJnaW46MS4waW4gMS4waW4gMS4waW4gMS4waW47fQ0KZGl2
LldvcmRTZWN0aW9uMQ0KCXtwYWdlOldvcmRTZWN0aW9uMTt9DQotLT48L3N0eWxlPg0KPC9oZWFk
Pg0KPGJvZHkgbGFuZz0iRU4tVVMiIGxpbms9IiMwNTYzQzEiIHZsaW5rPSIjOTU0RjcyIiBzdHls
ZT0id29yZC13cmFwOmJyZWFrLXdvcmQiPg0KPGRpdiBjbGFzcz0iV29yZFNlY3Rpb24xIj4NCjxw
IGNsYXNzPSJNc29Ob3JtYWwiPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+V2UgYXJlIHBsZWFz
ZWQgdG8gYW5ub3VuY2UgdGhhdCB0aGUgTHVzdHJlIDIuMTwvc3Bhbj41PHNwYW4gc3R5bGU9ImNv
bG9yOmJsYWNrIj4uPC9zcGFuPjY8c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPiBSZWxlYXNlIGhh
cyBiZWVuIGRlY2xhcmVkIEdBIGFuZCBpcyBhdmFpbGFibGUgZm9yJm5ic3A7PC9zcGFuPjxhIGhy
ZWY9Imh0dHBzOi8vZG93bmxvYWRzLndoYW1jbG91ZC5jb20vcHVibGljL2x1c3RyZS9sdXN0cmUt
Mi4xNS42LyI+ZG93bmxvYWQ8L2E+PGEgaHJlZj0iaHR0cHM6Ly9kb3dubG9hZHMuaHBkZC5pbnRl
bC5jb20vcHVibGljL2x1c3RyZS9sdXN0cmUtMi4xMS4wLyI+Jm5ic3A7PC9hPjxzcGFuIHN0eWxl
PSJjb2xvcjpibGFjayI+Lg0KIFlvdSBjYW4gYWxzbyBncmFiIHRoZSBzb3VyY2UgZnJvbTwvc3Bh
bj48YSBocmVmPSJodHRwczovL2dpdC53aGFtY2xvdWQuY29tLz9wPWZzL2x1c3RyZS1yZWxlYXNl
LmdpdDthPXRhZztoPXJlZnMvdGFncy8yLjE1LjYiPiZuYnNwO2dpdDwvYT48c3BhbiBsYW5nPSJF
Ti1DQSI+PG86cD48L286cD48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCI+PHNwYW4g
c3R5bGU9ImNvbG9yOmJsYWNrIj4mbmJzcDs8L3NwYW4+PHNwYW4gbGFuZz0iRU4tQ0EiPjxvOnA+
PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiIHN0eWxlPSJtYXJnaW4tcmln
aHQ6LjVpbiI+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj5EZXRhaWxzIG9mIGNoYW5nZXMgc2lu
Y2UmbmJzcDs8L3NwYW4+PGEgaHJlZj0iaHR0cHM6Ly93aWtpLmx1c3RyZS5vcmcvTHVzdHJlXzIu
MTUuNV9DaGFuZ2Vsb2ciIHRpdGxlPSJodHRwczovL3dpa2kubHVzdHJlLm9yZy9MdXN0cmVfMi4x
Mi44X0NoYW5nZWxvZyI+PHNwYW4gc3R5bGU9ImNvbG9yOndpbmRvd3RleHQiPjIuMTUuNTwvc3Bh
bj48L2E+PHNwYW4gY2xhc3M9ImFwcGxlLWNvbnZlcnRlZC1zcGFjZSI+PHNwYW4gc3R5bGU9ImNv
bG9yOmJsYWNrIj4mbmJzcDs8L3NwYW4+PC9zcGFuPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+
Y2FuDQogYmUgZm91bmQgaW4gdGhlJm5ic3A7PC9zcGFuPjxhIGhyZWY9Imh0dHBzOi8vd2lraS5s
dXN0cmUub3JnL0x1c3RyZV8yLjE1LjZfQ2hhbmdlbG9nIj48c3BhbiBzdHlsZT0iY29sb3I6d2lu
ZG93dGV4dCI+Mi4xNS42IGNoYW5nZSBsb2cuPC9zcGFuPjwvYT48c3BhbiBsYW5nPSJFTi1DQSIg
c3R5bGU9ImZvbnQtc2l6ZToxMS4wcHQ7Y29sb3I6YmxhY2siPjxvOnA+PC9vOnA+PC9zcGFuPjwv
cD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiIHN0eWxlPSJjYXJldC1jb2xvcjogcmdiKDAsIDAsIDAp
O2ZvbnQtdmFyaWFudC1jYXBzOiBub3JtYWw7b3JwaGFuczogYXV0bzt0ZXh0LWFsaWduOnN0YXJ0
O3dpZG93czogYXV0bzstd2Via2l0LXRleHQtc2l6ZS1hZGp1c3Q6IGF1dG87LXdlYmtpdC10ZXh0
LXN0cm9rZS13aWR0aDogMHB4O3dvcmQtc3BhY2luZzowcHgiPg0KPHNwYW4gc3R5bGU9ImNvbG9y
OmJsYWNrIj4mbmJzcDs8L3NwYW4+PHNwYW4gbGFuZz0iRU4tQ0EiIHN0eWxlPSJjb2xvcjpibGFj
ayI+PG86cD48L286cD48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCIgc3R5bGU9ImNh
cmV0LWNvbG9yOiByZ2IoMCwgMCwgMCk7Zm9udC12YXJpYW50LWNhcHM6IG5vcm1hbDtvcnBoYW5z
OiBhdXRvO3RleHQtYWxpZ246c3RhcnQ7d2lkb3dzOiBhdXRvOy13ZWJraXQtdGV4dC1zaXplLWFk
anVzdDogYXV0bzstd2Via2l0LXRleHQtc3Ryb2tlLXdpZHRoOiAwcHg7d29yZC1zcGFjaW5nOjBw
eCI+DQo8c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPlRoZXJlIDwvc3Bhbj5hcmU8c3BhbiBzdHls
ZT0iY29sb3I6YmxhY2siPiB0aGUgZm9sbG93aW5nIG5vdGFibGUgZW5oYW5jZW1lbnQgb3ZlciAy
LjE1Ljwvc3Bhbj41PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj46PC9zcGFuPjxzcGFuIGxhbmc9
IkVOLUNBIiBzdHlsZT0iY29sb3I6YmxhY2siPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNs
YXNzPSJNc29Ob3JtYWwiIHN0eWxlPSJjYXJldC1jb2xvcjogcmdiKDAsIDAsIDApO2ZvbnQtdmFy
aWFudC1jYXBzOiBub3JtYWw7b3JwaGFuczogYXV0bzt0ZXh0LWFsaWduOnN0YXJ0O3dpZG93czog
YXV0bzstd2Via2l0LXRleHQtc2l6ZS1hZGp1c3Q6IGF1dG87LXdlYmtpdC10ZXh0LXN0cm9rZS13
aWR0aDogMHB4O3dvcmQtc3BhY2luZzowcHgiPg0KPGI+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNr
O2JhY2tncm91bmQ6d2hpdGUiPiZuYnNwOzwvc3Bhbj48L2I+PHNwYW4gbGFuZz0iRU4tQ0EiIHN0
eWxlPSJmb250LXNpemU6MTQuMHB0O2NvbG9yOmJsYWNrIj4mbmJzcDs8L3NwYW4+PHNwYW4gbGFu
Zz0iRU4tQ0EiPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29Ob3JtYWwiPjxi
PjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+UkhFTCA5Ljwvc3Bhbj41PC9iPjxzcGFuIHN0eWxl
PSJjb2xvcjpibGFjayI+DQo8c3BhbiBzdHlsZT0iYmFja2dyb3VuZDp3aGl0ZSI+aXMgbm93IHN1
cHBvcnRlZCBmb3IgY2xpZW50czxzcGFuIGNsYXNzPSJhcHBsZS1jb252ZXJ0ZWQtc3BhY2UiPiZu
YnNwOzwvc3Bhbj48L3NwYW4+Jm5ic3A7ICg8L3NwYW4+PGEgaHJlZj0iaHR0cHM6Ly9qaXJhLndo
YW1jbG91ZC5jb20vYnJvd3NlL0xVLTE4Mzg3Ij48c3BhbiBzdHlsZT0iY29sb3I6d2luZG93dGV4
dCI+TFUtMTgzODc8L3NwYW4+PC9hPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+KTwvc3Bhbj48
L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBsYW5nPSJFTi1DQSIgc3R5bGU9ImZvbnQt
c2l6ZToxMS4wcHQiPjxvOnA+Jm5ic3A7PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29O
b3JtYWwiPjxzcGFuIHN0eWxlPSJjb2xvcjpibGFjayI+UGxlYXNlIGxvZyBhbnkgaXNzdWVzIGZv
dW5kIGluIHRoZSZuYnNwOzwvc3Bhbj48YSBocmVmPSJodHRwczovL2ppcmEud2hhbWNsb3VkLmNv
bS8iPjxzcGFuIHN0eWxlPSJjb2xvcjpwdXJwbGUiPmlzc3VlIHRyYWNraW5nIHN5c3RlbTwvc3Bh
bj48L2E+PHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4uPC9zcGFuPjxzcGFuIGxhbmc9IkVOLUNB
IiBzdHlsZT0iY29sb3I6YmxhY2siPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJN
c29Ob3JtYWwiIHN0eWxlPSJjYXJldC1jb2xvcjogcmdiKDAsIDAsIDApO2ZvbnQtdmFyaWFudC1j
YXBzOiBub3JtYWw7b3JwaGFuczogYXV0bzt0ZXh0LWFsaWduOnN0YXJ0O3dpZG93czogYXV0bzst
d2Via2l0LXRleHQtc2l6ZS1hZGp1c3Q6IGF1dG87LXdlYmtpdC10ZXh0LXN0cm9rZS13aWR0aDog
MHB4O3dvcmQtc3BhY2luZzowcHgiPg0KPHNwYW4gc3R5bGU9ImNvbG9yOmJsYWNrIj4mbmJzcDs8
L3NwYW4+PHNwYW4gbGFuZz0iRU4tQ0EiIHN0eWxlPSJjb2xvcjpibGFjayI+PG86cD48L286cD48
L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1zb05vcm1hbCIgc3R5bGU9ImNhcmV0LWNvbG9yOiByZ2Io
MCwgMCwgMCk7Zm9udC12YXJpYW50LWNhcHM6IG5vcm1hbDtvcnBoYW5zOiBhdXRvO3RleHQtYWxp
Z246c3RhcnQ7d2lkb3dzOiBhdXRvOy13ZWJraXQtdGV4dC1zaXplLWFkanVzdDogYXV0bzstd2Vi
a2l0LXRleHQtc3Ryb2tlLXdpZHRoOiAwcHg7d29yZC1zcGFjaW5nOjBweCI+DQo8c3BhbiBzdHls
ZT0iY29sb3I6YmxhY2siPlRoYW5rcyB0byBhbGwgdGhvc2Ugd2hvIGhhdmUgY29udHJpYnV0ZWQg
dG8gdGhlIGNyZWF0aW9uIG9mIHRoaXMgcmVsZWFzZS48L3NwYW4+PHNwYW4gbGFuZz0iRU4tQ0Ei
IHN0eWxlPSJjb2xvcjpibGFjayI+PG86cD48L286cD48L3NwYW4+PC9wPg0KPHAgY2xhc3M9Ik1z
b05vcm1hbCIgc3R5bGU9ImNhcmV0LWNvbG9yOiByZ2IoMCwgMCwgMCk7Zm9udC12YXJpYW50LWNh
cHM6IG5vcm1hbDtvcnBoYW5zOiBhdXRvO3RleHQtYWxpZ246c3RhcnQ7d2lkb3dzOiBhdXRvOy13
ZWJraXQtdGV4dC1zaXplLWFkanVzdDogYXV0bzstd2Via2l0LXRleHQtc3Ryb2tlLXdpZHRoOiAw
cHg7d29yZC1zcGFjaW5nOjBweCI+DQo8c3BhbiBzdHlsZT0iY29sb3I6YmxhY2siPiZuYnNwOzwv
c3Bhbj48c3BhbiBsYW5nPSJFTi1DQSIgc3R5bGU9ImNvbG9yOmJsYWNrIj48bzpwPjwvbzpwPjwv
c3Bhbj48L3A+DQo8cCBjbGFzcz0iTXNvTm9ybWFsIiBzdHlsZT0iY2FyZXQtY29sb3I6IHJnYigw
LCAwLCAwKTtmb250LXZhcmlhbnQtY2Fwczogbm9ybWFsO29ycGhhbnM6IGF1dG87dGV4dC1hbGln
bjpzdGFydDt3aWRvd3M6IGF1dG87LXdlYmtpdC10ZXh0LXNpemUtYWRqdXN0OiBhdXRvOy13ZWJr
aXQtdGV4dC1zdHJva2Utd2lkdGg6IDBweDt3b3JkLXNwYWNpbmc6MHB4Ij4NCjxzcGFuIHN0eWxl
PSJjb2xvcjpibGFjayI+VGhlIG5leHQgTFRTIHJlbGVhc2Ugd2lsbCBiZSAyLjE1Ljwvc3Bhbj43
PHNwYW4gbGFuZz0iRU4tQ0EiPjxvOnA+PC9vOnA+PC9zcGFuPjwvcD4NCjxwIGNsYXNzPSJNc29O
b3JtYWwiPjxzcGFuIGxhbmc9IkVOLUNBIj48bzpwPiZuYnNwOzwvbzpwPjwvc3Bhbj48L3A+DQo8
L2Rpdj4NCjwvYm9keT4NCjwvaHRtbD4NCg==

--_000_A6A3005C542A4061B179E83011FA2B45whamcloudcom_--

--===============8966364723362533465==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8966364723362533465==--
