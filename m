Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8EE75C433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 27 Dec 2021 15:24:01 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3EE093A4D09;
	Mon, 27 Dec 2021 07:23:58 -0800 (PST)
Received: from NAM10-DM6-obe.outbound.protection.outlook.com
 (mail-dm6nam10on2080.outbound.protection.outlook.com [40.107.93.80])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EC5D73A4069
 for <lustre-devel@lists.lustre.org>; Mon, 27 Dec 2021 07:23:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Kcmvil8wfv+DDxWvM101JXUDx+ZibNgmggjcxHVhzObJX/8ZtbqRj7O1ZDWaCIBk73wwpptcsySaueT3nnnDw2I/7k7U9VjWu2+jRSHzBS3Bxsz0KpWJlh6xRTQf35g/XuKRFneyFQDkMjceBQmHFsAUP08NrDoV5oylBtzE+cVWPp8BfgZxke9QrSktZhQwf7sXrDSUcze0h/GApwfDK09ICmPjY7EVwPmcm99im6+2g4iWF0JBRI9EmhtPfCoNyIbtiNJMR49fvXtWcN9MGDMSMFngX7YbXp0zoZ3vCxznoatpbP0tOSW02dpv6UjHAIucf6GYrCaK1AWxlXFtfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=ZBiHuusJ3FTue99noAKOGEg4/tvrzfCSOpHRSNZrAmk=;
 b=JGJp5iuZ0OqIeIwN2E+D0OGuGma5VMYWoB4Z5iMQ4LAncKKHiLC4YzG5acmDpUSvr4/Q+j7hO3A95E7Foh/PTQgn6uxjxX42DoaC1yRppapgXvtPCvKNrloPw0HLtMm3RftBRg6IzLons3lZr4EQDiHUPizpLIftMi3HTyTMvseIXs/7TOpOYXnADBoS3bA1uytkrSHEix3dVsvcdvgMTKtSLq7+nXbCXy7vkmaDcOyEaGdrfIQCB+B9UIKL0SGVB3xHgwQWOVhZ5Sgb6xlXbzcnHRobr0IjcA+H/BqJr9YBt1KdsMx+vYociKhQUOZElFuQ7gTPEAsNCx1mG034Yg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=whamcloud.com; dmarc=pass action=none
 header.from=whamcloud.com; dkim=pass header.d=whamcloud.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=whamcloud.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZBiHuusJ3FTue99noAKOGEg4/tvrzfCSOpHRSNZrAmk=;
 b=K0dDxFneIbJYLkVJPCuRlrA5iuLF+Knr6gWYC+n9vdTrDSHJ8hVFaMDfXxskXAvqYuiAIFQJ/GF5+jRHkZiW7IhDFqtsrzCRqWcJAsv8u4nKRwmERxLhnx/n4K5t9Me3KtvOVO9q1vKA/KpELnO3f/dVuip0wXhxH6xNy0e90kM=
Received: from BN6PR19MB0146.namprd19.prod.outlook.com (2603:10b6:405:6b::23)
 by BN6PR19MB3172.namprd19.prod.outlook.com (2603:10b6:405:7b::28)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.4823.21; Mon, 27 Dec
 2021 15:23:49 +0000
Received: from BN6PR19MB0146.namprd19.prod.outlook.com
 ([fe80::6c29:fb73:8830:3480]) by BN6PR19MB0146.namprd19.prod.outlook.com
 ([fe80::6c29:fb73:8830:3480%7]) with mapi id 15.20.4823.023; Mon, 27 Dec 2021
 15:23:48 +0000
To: Xinliang Liu <xinliang.liu@linaro.org>
Thread-Topic: Lustre Arm stuff status and work plan
Thread-Index: AQHX8lZb6p5/653Ee0+vr6HXAC45zaw6ro4AgAUOLoCABkz3AIAAfR0A
Date: Mon, 27 Dec 2021 15:23:48 +0000
Message-ID: <7AAC4FDA-AC84-4E73-83AB-130B6BD3AE1B@whamcloud.com>
References: <CAKoKPby+hn5+py-f11c31Po241871un0v=SQM+Cc6_hzvxW8uA@mail.gmail.com>
 <CAKoKPbxTcSxGzASKyVhiv_7W3OY6x3DRtkcTu8hzvLM+4-PzZw@mail.gmail.com>
 <6C592E3F-0437-4776-BB29-C5EE489C5FAE@whamcloud.com>
 <CAKoKPbxmvn7GVc6wsYrLP_HD8SpNMVFfSFdiZMo-5ZXqS-HSdg@mail.gmail.com>
In-Reply-To: <CAKoKPbxmvn7GVc6wsYrLP_HD8SpNMVFfSFdiZMo-5ZXqS-HSdg@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=whamcloud.com;
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f03c278d-9087-4551-f888-08d9c94ce19c
x-ms-traffictypediagnostic: BN6PR19MB3172:EE_
x-microsoft-antispam-prvs: <BN6PR19MB317255988CAE7056289D0468AC429@BN6PR19MB3172.namprd19.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
x-microsoft-antispam-message-info: OHE7rRJtVxjenFGpTe/oA9yDIHdI/za70gVIWKDi/u4MRD6gNWnSdxgmaz51mc/s903bLw6L6pclqn7YjJWqbhCRiV40ji/N+4TcRG6wtw8zF7sFcqOJwXJkqmOKoTZ1d0oaBBf0puATLHSs3VtiKGsMjS1k4prvj2MA0YuyAqbKeGMV54FMHZ/64YPV9o+bomIZb5RlIAEFi405gI3V5PwR8i+Nt3kM++oY4nluf261WrrtIuZ5Bj3O/kUbRej/IWF4tU4eZ2H4cDmXXmeKbls9dTNdUuH9Qlcjr7w0gwdxMU22l4QkqL134jQzZ4KEB2pHNcCpqSUZqFq/zznMO1InhUazMPEqL/jV3MygBmlJCbZQ6/e1vJF4iGj2KZc9PUZWvvd+2HktDCq/e7anHd5IUY+BhGxeBG5obuswU1kawU49x4kM2o1+uuU9PBe0NShAqZJHRu2I8I4koTEFJl/dsEiXRx1CMBofmMPQ7SiKVCwzPkN3P54Mp8AWe/23lcNCBd4Lh9i4EYiRY85v25oGQaILKz2oAIpFOj37CXxVTrpXcpSfzP/5QDLm4HCyJa3mmezU/f9Vdk42uhni/umlud4bXHOh5R8sXEAS1ggwPtKK3sRiuch8p405dkHEEtRm0nTzQ5jU5glOZ6QAsbtz/TmpjUqk4DuDBbwvoLCKXbB2qfPF3EI8qxVGDc6QFtxte39UjSBZ58+8pdhtj1L7E4148KU+V37nepKXx/bJLLFGi+iYfLFyedK4JrIQZkS57Vq9L92e2B4UIQCs2Q==
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:BN6PR19MB0146.namprd19.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(4636009)(366004)(508600001)(64756008)(66556008)(66476007)(8936002)(66446008)(2616005)(66946007)(76116006)(6512007)(71200400001)(8676002)(186003)(316002)(4326008)(2906002)(86362001)(36756003)(54906003)(6506007)(53546011)(33656002)(38070700005)(26005)(38100700002)(6916009)(6486002)(122000001)(83380400001)(5660300002)(13693001)(45980500001);
 DIR:OUT; SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?UEnhlvOV8lwjgZRFHfYfv6J0MbjZ+PGDXqgr6ejtTspujgT+ZuraNkThr7JO?=
 =?us-ascii?Q?Uc4/zzrc1Vxm96CpnbGcMkxBCbvPkD+g35oQdSsHWnxJAq2lDMtNvx7jUkKp?=
 =?us-ascii?Q?UgT1aqpRlkh7eoRCR5TB2bnjZmLyw9SJI5ixDr1qUQzVXOx7EDKZHm9bN9zo?=
 =?us-ascii?Q?BQI+pf4xb1lcJ1XOqxbFMKOKoFR6/XJN3O/iJXLcB20eh3BGiODpg0rN17IJ?=
 =?us-ascii?Q?UJuElBb8nOb4hKiuk/uYPfyEX0ht3djPB0gx+O/CDh3Td7wSDQHhXa7FpuOH?=
 =?us-ascii?Q?sIX4p5IEjHJ4a3oDqw0iI6efwoTVGXvlRubFOZIEIYjyzyGHG+dG75pjFCWJ?=
 =?us-ascii?Q?1O3WMxvaR3QDmKn7f/mKmsnSJK43Q1bQjBTqXsGXdxfQZ0cbS3zndntW0HEH?=
 =?us-ascii?Q?+MHP42mMbAo4KxkwBp1pRhHSziaXMdJqwjPccmmVLwrDpezrpMu4CaafAtR9?=
 =?us-ascii?Q?tFGPBCEL6s8/Sm2sCb+lzPD8Q5R5xBd2IwqOf/6L29KJsU6isIforpZN8Wix?=
 =?us-ascii?Q?DLZw89k3RTRIq3mYCZPmB4eiLhBqLw2VgmfO2C2GcJKLEQ7zEEG2aHOYSsdL?=
 =?us-ascii?Q?a17jK+wojAJVMNcmbTYRNsmLSomw/TMvQdsgmmXy9e6HxTf2G/dPvgHbOiYw?=
 =?us-ascii?Q?OJnY7uV7m6l4WOqQsY6tOqhHtq2Xe7SxPp0IHTm7fyMZE+7aBnnGD2mJ4Kal?=
 =?us-ascii?Q?vjy9L5qjrZTboQ4VAJy7d+WydkLFW13N/Me/11YkRDFwaBpTfNjC2rORjbcF?=
 =?us-ascii?Q?igHQse097piyJIgSs57/8ofT/fU6MiC9/ty6GjwpEwD3iHxhYgTct6zSyvEX?=
 =?us-ascii?Q?sLuIWf2OMh7OoElHSM+b7f662hOFt6Jryd+Tdk3hNjUbehOX45dCq+mr7nEt?=
 =?us-ascii?Q?7hdKz0gMGQ0ab7Inr0bRIfWNhU8MMb5X4vlr0S+SI26WqTaFKwA1M2opOGKj?=
 =?us-ascii?Q?OE+6MsBVaJU2+ZSeu526qB0wWd2tGziRJxgICo5/pNMQzmdCwJWaG0cvLoJd?=
 =?us-ascii?Q?+ojYsgLIfMYzxfSrGFYfTwZb4MA/PdRA4B1oKvEWPp7JdUcEL+bhRjpJw8D/?=
 =?us-ascii?Q?yH0B2jA2b5jxKTIkeiYJ0qKvlg0XDtcu9Jo16AtZ5ubzMbRqanl3frpbnDiA?=
 =?us-ascii?Q?NZGYlbq6pQwN61j8ylVTf9FyQUM6inQdHaAAQ74f7M3VE5Yy8M+tzV2Q8QUq?=
 =?us-ascii?Q?wA90nMFPY6yKR2dRpUZzr6xIXgWl11jr2mNTSAkX9XnK729qL2fpX3prObXR?=
 =?us-ascii?Q?709of5qTvKRE6yKLg1RYiGXj46SdKyR5jTAOsRNcJsoHTup85Sing2zFUA1o?=
 =?us-ascii?Q?rbO7ZMBpbcSFsMy00iSA/7aAPXm/swwlydWho96gWbGiBiolohq6yjCRGipJ?=
 =?us-ascii?Q?tfJ0Fzt7O5zNSlBpfZEKl/MWATyh7dCuPUVUNI+wsIyaYr+J0oVyMHSuy8FD?=
 =?us-ascii?Q?HMLe1GkOz0gd/A4tS5d+hEUczEuDTG9lNmYP8Fh+vvWWRPy7pLWIBjrtJB1h?=
 =?us-ascii?Q?OCEMF7nXYshMNNQwECYakEsshhFy1z9P5kcclN9uauvY5ZL1DZz+2Fis28bt?=
 =?us-ascii?Q?pDrVM5/Vdx2yCx2t/xw=3D?=
Content-ID: <252BFE953A8FB9488E48E7163C46085E@namprd19.prod.outlook.com>
MIME-Version: 1.0
X-OriginatorOrg: whamcloud.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: BN6PR19MB0146.namprd19.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f03c278d-9087-4551-f888-08d9c94ce19c
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Dec 2021 15:23:48.7306 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 753b6e26-6fd3-43e6-8248-3f1735d59bb4
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: A6bVbfP5eD/NNrzmptFQwi08DzqVUt7nifGYRb03FOsnif1I0kXStn7iSr6Mll25
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN6PR19MB3172
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>



> On Dec 27, 2021, at 2:56 AM, Xinliang Liu <xinliang.liu@linaro.org> wrote:
> 
> And if we run some kind of tests externally in our end, we can see the test result (pass or not, running log link) displayed on the gerrit patch page as the community running tests. 
> We want to make our test results public to the Lustre community, so that developers can see the test results and adjust the patch if necessary. Thus avoiding breaking previous Arm work.
> That can be made via reporting results into Maloo DB, right? Am I understanding correctly?

In general people are more likely to see results when you post a comment to gerrit with said results.
Maloo is just one place to link to to actually let people see the results, but you can link to external resources too
like e.g. gatekeeper janitor helper does or assuming the information is small enough it could be entirely contained
in the comment (like say for a build failure)

> We will look into the links and evaluate on setting up our own or self-hosted test infra and see if we can make it.
> Such as,
> 1. How many VMs resources for the test infra and test running;
> 2. Other requirements for the self-hosted test infra; 
> 3. Work items to be done;
> ..
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
