Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 04F5CC27C53
	for <lustre-devel@archiver.kernel.org>; Wed, 12 Jun 2024 22:54:30 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4W017p1dHJz22Ry;
	Wed, 12 Jun 2024 15:54:30 -0700 (PDT)
Received: from mx0a-00069f02.pphosted.com (mx0a-00069f02.pphosted.com
 [205.220.165.32])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4W017d0Xdpz1wNQ
 for <lustre-devel@lists.lustre.org>; Wed, 12 Jun 2024 15:54:21 -0700 (PDT)
Received: from pps.filterd (m0246629.ppops.net [127.0.0.1])
 by mx0b-00069f02.pphosted.com (8.18.1.2/8.18.1.2) with ESMTP id 45CFWnZR013595;
 Wed, 12 Jun 2024 22:54:20 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=
 from:to:cc:subject:date:message-id:references:in-reply-to
 :content-type:mime-version; s=corp-2023-11-20; bh=Io8ADYZOdRp4Qc
 tHn9OjxvE/wW0ER4e1ULOeWFKE0Eo=; b=SQAEzmd+5Y8jmG3nJ0uAjjw8vTnzxe
 52gRpsUghqaFum7n6bKXr7oNXK//Z0c0spprOih49wRje/0WGFAmAwoVuCSK1dqo
 nbFTLhLebCe4nGP2WemCAN0CN4uda11ng++Dy6r8FoOBhkuZyEN1UaNKHQ1RshmH
 YywoM/iy64cDsH79j+CXuAdbX7Jtom2QnQNkT9hCETW+a3nBhHV3xyTlQxdBcwcn
 iFCNg2Ojw4DDXNyLx2vLofmx5h4HEWvGnQ1fMBGPYV+ZllKS6xv6o5xJ6EkQ8dcE
 P3Yviggk0u+crgb5bHJt6rMKlf4LEvu/PGMb0VkuVmT6vOdKYJIiOzEA==
Received: from phxpaimrmta03.imrmtpd1.prodappphxaev1.oraclevcn.com
 (phxpaimrmta03.appoci.oracle.com [138.1.37.129])
 by mx0b-00069f02.pphosted.com (PPS) with ESMTPS id 3ymh7fr53x-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
 Wed, 12 Jun 2024 22:54:19 +0000 (GMT)
Received: from pps.filterd
 (phxpaimrmta03.imrmtpd1.prodappphxaev1.oraclevcn.com [127.0.0.1])
 by phxpaimrmta03.imrmtpd1.prodappphxaev1.oraclevcn.com (8.17.1.19/8.17.1.19)
 with ESMTP id 45CMqglW012525; Wed, 12 Jun 2024 22:54:19 GMT
Received: from nam12-bn8-obe.outbound.protection.outlook.com
 (mail-bn8nam12lp2168.outbound.protection.outlook.com [104.47.55.168])
 by phxpaimrmta03.imrmtpd1.prodappphxaev1.oraclevcn.com (PPS) with ESMTPS id
 3ynca05ees-1
 (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
 Wed, 12 Jun 2024 22:54:18 +0000
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=BMoK+vI9axHi/6YvfkAQ0Kz0zpFh/V2oIkj7Hexr4NzpgO/tbOW8WR2Dg4+5QaWJ36vbP/0pr3wi/cnA1MQTvaeLdT/ccw8VeT66y2Y3o6/gyoddqdAhxbopkY8jaCQKvaGLt72SQsnpWobGIJ+UY4mZX2Vl/bLDEQ0VYIbPZbO6Kp6wibf2mSa7XWHZ9xvPGLq9YY8b/oRqizRCwLWbQ/1dbZkON82+KJBa49Y3WG+iK2ihzPx2Khw12dpTNO1PNYppZnwlQOkZDm0J4IlSO3lkXnIJVh2JZOXq4M/EWja052kSqfjuj7r5rWLSa4nsRj5Ylb/uYWXWD/iPDe3WzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com; 
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=Io8ADYZOdRp4QctHn9OjxvE/wW0ER4e1ULOeWFKE0Eo=;
 b=K+BBMCudL7218vMpC6sDeLJ1ISD3HpMRhwFBrsqSsT9+gQ4gOFin44aQnroYa+sX2WWmJ9cTpg8dgO5Ad9whJilbU3gUhy2zcjukleOlIRlLLlP+kjA39b2pIeWRNwfbvLFYx9/8gWP+EYUpPTvPa3oMeYJy7ZwuAkcaZsF3DcFs7GFomOZ/lyv5r3S4rtvChGU9lmNpdT8mvjAXiR59QeScmIFVrAxtSF4f/Sb8s1kkYdYwYKMeH/KfDRPNoN4kmALAWwgqAdYpMcy1VBbStwmne+3GI3hgKS9dxw8mDoXmB4HhaKQBY/qBJpN4lPk9uOWOGyDGIjpNFwjnr2MubQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=oracle.com; dmarc=pass action=none header.from=oracle.com;
 dkim=pass header.d=oracle.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=oracle.onmicrosoft.com; s=selector2-oracle-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Io8ADYZOdRp4QctHn9OjxvE/wW0ER4e1ULOeWFKE0Eo=;
 b=yl2gZ/4X0HHf2kIf1hIl1pM3bjUOHl4uMQh/uvU5iJjDQGdinT1lut4ZlZ6yBwU1CjArrHVcCKDDub7wTxbJLIkRo/dXd2XmJTOLvVBr7VMffUy652N5vBCuOzBieOdmXuh79XIHLz7O8kCBiVlsLKcEn1VFe5QiTXNzDwh1Qb8=
Received: from SN6PR10MB2813.namprd10.prod.outlook.com (2603:10b6:805:cc::12)
 by PH0PR10MB4773.namprd10.prod.outlook.com (2603:10b6:510:3e::22)
 with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.7633.36; Wed, 12 Jun
 2024 22:54:16 +0000
Received: from SN6PR10MB2813.namprd10.prod.outlook.com
 ([fe80::d83d:73f5:3898:215a]) by SN6PR10MB2813.namprd10.prod.outlook.com
 ([fe80::d83d:73f5:3898:215a%6]) with mapi id 15.20.7633.036; Wed, 12 Jun 2024
 22:54:16 +0000
To: Saisha Kamat <skamat1@charlotte.edu>, Andreas Dilger
 <adilger@whamcloud.com>
CC: lustre-devel <lustre-devel@lists.lustre.org>
Thread-Topic: [External] : Re: [lustre-devel] Inquiry Regarding Checksum
 Support for Lustre Extended Attributes
Thread-Index: AQHavRfJ45pBMt1aJkqT5clHLuySSLHEtzab
Date: Wed, 12 Jun 2024 22:54:16 +0000
Message-ID: <SN6PR10MB2813B942D02E953B1786419899C02@SN6PR10MB2813.namprd10.prod.outlook.com>
References: <CACyzrcS7iBzxmzUqLY7vo0gE_=D3v+33HZ_gGeYe6rgkv0YYOg@mail.gmail.com>
 <D862AC2B-4FFA-4F82-992F-246E24BF4C72@whamcloud.com>
In-Reply-To: <D862AC2B-4FFA-4F82-992F-246E24BF4C72@whamcloud.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
msip_labels: 
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: SN6PR10MB2813:EE_|PH0PR10MB4773:EE_
x-ms-office365-filtering-correlation-id: 5dbb9258-4bd2-45bc-b306-08dc8b3295fd
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;
 ARA:13230034|376008|1800799018|366010|3613699006|38070700012; 
x-microsoft-antispam-message-info: =?us-ascii?Q?xtXVLIF+PBKgQWM7VDH7sTQ10Ljq9FIHF0d+hO3k/+BcY6xO3t8ch97gXeL3?=
 =?us-ascii?Q?9xO0NNuMB3QBY5ku+5cQEWUDmpE9qdoSABgKBl+d7ol7g/qoW8qPoG/sI7rk?=
 =?us-ascii?Q?GiWrjC2FBqLtL8FlUdlus286nzcRM6wA2uiFSaMLfwwfhZdHI2WJLa0Pnv5F?=
 =?us-ascii?Q?5VYLPsxT8L0Q+Z69zaqIAvAzlZZTOm9nQNtQptmObs7it4BWWvlRlz5AAb1Q?=
 =?us-ascii?Q?GXOTb32JqHPYJNYuN01RNMqsYa6pP6ZkhaNCJPVLUO0/shXfwyecj3fckwXz?=
 =?us-ascii?Q?6wGd49J795yH2QzwILqo2HN+s7QGC1TSxpKciBqOZMs7eUSJoVRRj5YxqH8a?=
 =?us-ascii?Q?sg99ovAiP2en9U3vZU3d0BuPbh/50o8OBq9V5nfFdd5hjc4N6wtF2AF/9WfH?=
 =?us-ascii?Q?U2nEfv/pTd70QsPQDO/0O2rHA0ayDsm0fNxp32Jqz4d5XQgEv+F0F64kaqMs?=
 =?us-ascii?Q?E93sngslIIywaALvJ1Oo2Z7uF/xgenRbZz4F2QKkFc3Fte5cNK5xAKPcu0Pu?=
 =?us-ascii?Q?jnGV9jr304PypdYEn17h+Mf+9pR6Xj/UM1NeOgvJf0d3JmHgJuNMo2uTXZe4?=
 =?us-ascii?Q?e8jWl7Jsh6TjqzdOwsHVd1fNXDEALuwkeaMvKM0fpEdU1mt8fiaWOxyskXsr?=
 =?us-ascii?Q?/FwZGrs+F7RUWOi0Z7R8WGJmT3hVGhp99sBdLwS2HDe5mBTq8Y5ZZxKuzKuj?=
 =?us-ascii?Q?nC4a6Si6MF9zpq365NzhJm2JeQg+nzrGEopkWYpRTeKP21JyzoOub07L0Sco?=
 =?us-ascii?Q?ddrdVRpSe4qR/tJgRHukmXQjiZLqQeRA+Oi2csaCZnVCmCI4W8oo6m9rf9P6?=
 =?us-ascii?Q?+FJitvQPrpXkyTvkyMUTFWbRsOcAH05BGFAccH5EveTXLqIK+70wb1EJhFhq?=
 =?us-ascii?Q?w3pBBDYFvdAU/gbTn3YSeRyw9I3BgLiOi4FCA/tXV+zbtWdRUCrQiIbIyyD3?=
 =?us-ascii?Q?Rc4pG2AaxrUagi78w5j0+36lYQ9qFw2YViUCzSVVvunEZ+xPy1r0I8CNmSTv?=
 =?us-ascii?Q?DIZaUPxzzo4lBqO9/5PkLVeusm0XBfyX4nxU6nzL333YEa0VmisSE9/Ssan0?=
 =?us-ascii?Q?bAZQSdxOWZzFGxFLE0gOb3f5HXvFM1m+n00thDJh0WsFhBvlpWof4xr+m1gn?=
 =?us-ascii?Q?UMLd6yltXJoqYHNTlh2sRqhGMflljQJd0awY5RFXkmd5IMymdQmiv5WzQ8V/?=
 =?us-ascii?Q?ghEgvBBbQ5bmoFcncedWqRW1GvkSulekajEVnejjxSNq1t6GIhJJu99MqCTV?=
 =?us-ascii?Q?30CY7ZYogxcARXNorwAtORwTYtoD88sgAhb5m7lur5nPhfoag+1tzr5Zjq1N?=
 =?us-ascii?Q?llGTjLNCjTb70cn8VIJ/0y7G6fWY4vIinBMTb4eeiKl/og=3D=3D?=
x-forefront-antispam-report: CIP:255.255.255.255; CTRY:; LANG:en; SCL:1; SRV:;
 IPV:NLI; SFV:NSPM; H:SN6PR10MB2813.namprd10.prod.outlook.com; PTR:; CAT:NONE;
 SFS:(13230034)(376008)(1800799018)(366010)(3613699006)(38070700012); DIR:OUT;
 SFP:1101; 
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?us-ascii?Q?MzXQz/gjuyFK0dYRu4Ml17iIiBLM3g9+yz8SmrH4103j/h1yDgUz94fBebL3?=
 =?us-ascii?Q?/sHeUWjp2fJ+makVJ6vP0yOphVPM4nfzlqL7NwWC72bbWIsEI6kQGofs7by7?=
 =?us-ascii?Q?Ty83wpj94CZT0QkKKod3nzQHsYbeS0Z0L/k1mJECJBtDoNfAQifKEPAv4/Az?=
 =?us-ascii?Q?bS4T7jUSiBIsglJMMs0ysjfnpKJlsB2pV9284K82TQDsPhSIiIQw59HytES2?=
 =?us-ascii?Q?yCZ/LBRv0JGoHkDrBJ/1vxlu1qgn3dwIAJ/wL0seNo85F5nicJ8inc83xb7d?=
 =?us-ascii?Q?XXLqHk5ApE3Sifsk6jbC1f4/AiwL48CVfe0vYvjkdtSwzuKhalD35+/KHnns?=
 =?us-ascii?Q?pew7oCEYBTdRTZAJ7PNg0QfAU6bPqhjkjpikQG4HuKCqtq6eUJKy/y1Lj+vA?=
 =?us-ascii?Q?doT5dRrHCXh1lq1p19F3peOACknQuB3ZoXhpBFOk3I+OR1Zv3VV41j0ncCyE?=
 =?us-ascii?Q?v8wAy8Mbw8vSt+84Bwq+GeSIBoZwTdoEK5cLvp8Qr0ywS0WJ7XKtBxvgC4+U?=
 =?us-ascii?Q?H1+Xlg4V2UbzhnL3aypDUXX3wX8PZ6U/apjn4TTZ0Bmm8dQWXycN8m96xQOd?=
 =?us-ascii?Q?89IbvkIbnzxgdYIt9+WtuTVt76YeWgwOWmvGGG793TfmSxEKCdqARYK84qKL?=
 =?us-ascii?Q?9SUg+IHrhhi8ViPz1HtjGLK4pjdo/+y2exNUZLnGhRVBmKmX6Tp4OMWDvg5C?=
 =?us-ascii?Q?j/Ey0gKJTrIIUn8FNNfwdDaAN7To9Kc2ZZ3+u8vAACZA6VPT7WTfWA20tkPv?=
 =?us-ascii?Q?S/rHQqWlUWBdnH1KhwAPs8sQds+ERosyyFh7Dgm/Dy9rHl0cLR1YfVIYBAMO?=
 =?us-ascii?Q?zQ4QNGNPR0Mzj7O2yeE+GLUnoIC4V2aMm9g+Nws0fByVzEg9mGD4uecOhl9Q?=
 =?us-ascii?Q?YjKS74nw+EaT+RrZCsQtpQX3xFVmYmm9yO60IOUQz+FJ6KFvqeQEmjNtbFZ4?=
 =?us-ascii?Q?d+loCAegMvwdaBvFAQtFO6+xj+sSQrLaZQOCbjUzIfM2ouVJKdKZ/zt+oC6s?=
 =?us-ascii?Q?4d069/G1maZ1FJgCPs/tOidmT+UpHS6g44yWEXsu6gWz2ubzOn1pJWjp+TXK?=
 =?us-ascii?Q?QDAR1MfELM68Ii7zaBo6lAIy0iN40Hhb9NfvjhTtZVke8O8NlrV16Ig71P76?=
 =?us-ascii?Q?w9ITECq52JAuerZ/RpJLKM/VyIicbK60EbxyAe2yXlCgwvVbofPf5Gv16fVt?=
 =?us-ascii?Q?sgbKeAQCV7wTx46LUrNd4JBDfqy+8n+qaVLhI5HosJDVRItuwrcKk/ic3QqF?=
 =?us-ascii?Q?9vjDKJjBQTmXO0ePkzwrZrHhfo4+SL5zpClmDZLmPa7i8/BoIfr931btvZKO?=
 =?us-ascii?Q?kMg4oynMUP5SJTmaleVHkzaAxpuiKyV7C/22s3kRZsWR3V9aCJJn0+7Ii5O0?=
 =?us-ascii?Q?jK/NZSfHW86IIMhv7ov/+Rbu9StZ7MgHx3HE8ZuBlqlRLDr83aF1XrBrHLsw?=
 =?us-ascii?Q?P/qvTz8pA8FnXNcWbNTbltdcrB7wk1x3nX62UmZdo4XSwf9lITWcQXLgR5Qc?=
 =?us-ascii?Q?1OsNguNJ9PZPLL2a0nBSl9pZ5k9wblTTvDzKYlmCZS0y5ItCp57nSMebOwcr?=
 =?us-ascii?Q?DVTge2bVGq1tWIf8KAKtncEqkKXZ/FqkxPH1Zcsr?=
MIME-Version: 1.0
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0: jibn82Hd4pR8IgVTRpjRW0yR7v8AH5FemTdOVfF+KSmvq3/k5BlfCjdRyRbVuesVNi158KzL9zPajw3CZ3vAZeAGNf1DKV0xrIaw7djWO1T3i3/eU/3MLoDOL3juC3o5KNLZdq8VYl+sa7AZ5QEIgY0s81hMO9ojzAYbZklqCJnXZZwBClPuoa3lJ5qh2EclsuTXyOYwxUNGPy6aoz8ngPwi2VmmEt3z4XYtx2BrUU5xWsVrQZZNF/GqBzjPQxdIdLw4UQW5IGx8TRidjcR1xc2B0bYbXpRnl/RmMtmyHZq1jrzsNXawLROsZLpXBwM/spdN8Q7+7JctWAOLZsmK2oBQbhHkKIWyIxBbe6+ImGpH00dgk6H1iD6wWjwM9UXcRHOoSPu3/6W27d+6DlEgkzk6Y/9Cv54bSsD0r0ZCRIqSjLnodW4AcZYFIK8u3iQji2VGh50hVL7Aj9qZ8Gl3Q86KOhobH5CxgT8YQeRSG7dFsrb3kompuZKdLgDnIo3iNZco34isLc5UJ9oKbu+e0zCcCAlGblZb9WyC7VMwywqXL6SL5OiPKKOraJYoyuUoeGtZbV2VtxaF7lR313uvR29R5FkEFMLJTahetZWXHGI=
X-OriginatorOrg: oracle.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: SN6PR10MB2813.namprd10.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5dbb9258-4bd2-45bc-b306-08dc8b3295fd
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Jun 2024 22:54:16.0474 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 9R3vlfuJdcENbxDMT1J0OeIl75J3wSVzXl4CwGDKd15h3K79tcUfpRM48CE2H6NHgDI0zxj2RAwLUbXCT0Yhy547p99SnXlRiCgOJkhQg/k=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH0PR10MB4773
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1039,Hydra:6.0.680,FMLib:17.12.28.16
 definitions=2024-06-12_10,2024-06-12_02,2024-05-17_01
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 mlxlogscore=999
 adultscore=0
 phishscore=0 suspectscore=0 malwarescore=0 mlxscore=0 spamscore=0
 bulkscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2405010000 definitions=main-2406120163
X-Proofpoint-GUID: yR1g4mooIh-E-B7WR5JjJvweiH0el_Bi
X-Proofpoint-ORIG-GUID: yR1g4mooIh-E-B7WR5JjJvweiH0el_Bi
Subject: Re: [lustre-devel] [External] : Re: Inquiry Regarding Checksum
 Support for Lustre Extended Attributes
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
From: Patrick Farrell via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Patrick Farrell <patrick.farrell@oracle.com>
Content-Type: multipart/mixed; boundary="===============5240547036403182670=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============5240547036403182670==
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_SN6PR10MB2813B942D02E953B1786419899C02SN6PR10MB2813namp_"

--_000_SN6PR10MB2813B942D02E953B1786419899C02SN6PR10MB2813namp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Andreas,

A few clarifying questions, partly for me and hopefully for Saisha as well =
as a non-Lustre expert.  The ldiskfs file system supported for Lustre disk =
targets is a modified ext4, so it inherits ext4 features for the local volu=
me, but not all of them are supported for ldiskfs formatted volumes.  So do=
es Lustre support use of metadata_csum (that's the relevant option, isn't i=
t?) when formatting ldiskfs?  Is it on by default?

Inferring from your comments, I think you're saying metadata_csums are (or =
can be) used on an ldiskfs volume.  But since they are just a local disk fe=
ature, they contribute only minimally to resiliency in Lustre, and Lustre m=
akes no use of them.  They can help protect against some damage to the loca=
l volume, but Lustre is unaware of them.

Do the metadata checksums extend to all ext4/ldiskfs extended attributes?  =
Are they done separately for individual xattrs or just for the whole inode?=
  The kernel wiki describes a possible implementation that credits someone =
named 'Andreas Dilger' ( :) ) with suggesting checksumming them under the i=
node checksum rather than separately, but I don't know what was actually im=
plemented.

Regards,
Patrick
________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of And=
reas Dilger via lustre-devel <lustre-devel@lists.lustre.org>
Sent: Wednesday, June 12, 2024 5:27 PM
To: Saisha Kamat <skamat1@charlotte.edu>
Cc: lustre-devel <lustre-devel@lists.lustre.org>
Subject: [External] : Re: [lustre-devel] Inquiry Regarding Checksum Support=
 for Lustre Extended Attributes

On Jun 12, 2024, at 12:35, Saisha Kamat via lustre-devel <lustre-devel@list=
s.lustre.org<mailto:lustre-devel@lists.lustre.org>> wrote:

Hello,

I hope this email finds you well.

My name is Saisha, and I am currently pursuing my Ph.D. at UNC-Charlotte, w=
ith a focus on research related to the Lustre File System. As part of my pr=
oject, I am exploring the possibility of utilizing checksums to verify Lust=
re extended attributes.

My understanding is that the ext4 file system supports checksums for extend=
ed attributes (xattrs). However, I am interested in whether this functional=
ity extends to Lustre as well.

Yes, the ext4 (and ZFS) xattr values have checksums.  No, the xattr checksu=
ms are neither managed or verified by Lustre, and only come into effect whe=
n they are passed on to the backing filesystem.  Conceivably, it would be p=
ossible to have a checksum (e.g. crc32c) for the xattr values in the MDS_GE=
TXATTR and MDS_SETXATTR RPCs, if this is something you are interested to co=
ntribute.

This could probably be done by overloading one of the 32-bit fields in the =
mdt_body for getxattr, and one in mdt_rec_reint for setxattr, but there is =
also "opportunistic" xattr prefetching done in the lookup RPC, so that woul=
d need to be covered as well.

Also, the checksum would also need to be kept with the xattrs in cache and =
verified on access, otherwise they could become corrupted in memory after t=
he RPC processing had completed.

Finally, there is no interface to specify or verify the xattr checksum in t=
he syscall interface, so there can be no guarantee that the data supplied i=
n the setxattr is correct, or remains correct after supplied to getxattr, b=
ut the window there is very small.

Cheers, Andreas

I would greatly appreciate it if you could provide some insights or direct =
me to relevant documentation on this matter. Any information or guidance yo=
u can offer would be invaluable to my research.

Thank you very much for your time and assistance.

Thanks and Regards,
Saisha
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org<https://urldef=
ense.com/v3/__http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org_=
_;!!ACWV5N9M2RV99hQ!NxZsGb9nGU3ZLJa1pn9PclSTh2QUuTOnSdBLFvT4cYZxHl-jq2z3TrA=
RWnu9vlkaS-diipwr7e73a1J0pgTw4Htt05quzd0a$>

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Whamcloud








--_000_SN6PR10MB2813B942D02E953B1786419899C02SN6PR10MB2813namp_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<style type=3D"text/css" style=3D"display:none;"> P {margin-top:0;margin-bo=
ttom:0;} </style>
</head>
<body dir=3D"ltr">
<div style=3D"font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, =
Calibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
Andreas,</div>
<div style=3D"font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, =
Calibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
A few clarifying questions, partly for me and hopefully for Saisha as well =
as a non-Lustre expert.&nbsp; The ldiskfs file system supported for Lustre =
disk targets is a modified ext4, so it inherits ext4 features for the local=
 volume, but not all of them are supported
 for ldiskfs formatted volumes.&nbsp; So does Lustre support use of metadat=
a_csum (that's the relevant option, isn't it?) when formatting ldiskfs?&nbs=
p; Is it on by default?</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
<br>
</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
Inferring from your comments, I think you're saying metadata_csums are (or =
can be) used on an ldiskfs volume.&nbsp; But since they are just a local di=
sk feature, they contribute only minimally to resiliency in Lustre, and Lus=
tre makes no use of them.&nbsp; They can help
 protect against some damage to the local volume, but Lustre is unaware of =
them.<br>
<br>
Do the metadata checksums extend to all ext4/ldiskfs extended attributes?&n=
bsp; Are they done separately for individual xattrs or just for the whole i=
node?&nbsp; The kernel wiki describes a possible implementation that credit=
s someone named 'Andreas Dilger' ( :) ) with
 suggesting checksumming them under the inode checksum rather than separate=
ly, but I don't know what was actually implemented.</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
<br>
Regards,</div>
<div class=3D"elementToProof" style=3D"font-family: Aptos, Aptos_EmbeddedFo=
nt, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; c=
olor: rgb(0, 0, 0);">
Patrick</div>
<div id=3D"appendonsend"></div>
<hr style=3D"display:inline-block;width:98%" tabindex=3D"-1">
<div id=3D"divRplyFwdMsg" dir=3D"ltr"><font face=3D"Calibri, sans-serif" st=
yle=3D"font-size:11pt" color=3D"#000000"><b>From:</b> lustre-devel &lt;lust=
re-devel-bounces@lists.lustre.org&gt; on behalf of Andreas Dilger via lustr=
e-devel &lt;lustre-devel@lists.lustre.org&gt;<br>
<b>Sent:</b> Wednesday, June 12, 2024 5:27 PM<br>
<b>To:</b> Saisha Kamat &lt;skamat1@charlotte.edu&gt;<br>
<b>Cc:</b> lustre-devel &lt;lustre-devel@lists.lustre.org&gt;<br>
<b>Subject:</b> [External] : Re: [lustre-devel] Inquiry Regarding Checksum =
Support for Lustre Extended Attributes</font>
<div>&nbsp;</div>
</div>
<div class=3D"" style=3D"word-wrap:break-word; line-break:after-white-space=
">On Jun 12, 2024, at 12:35, Saisha Kamat via lustre-devel &lt;<a href=3D"m=
ailto:lustre-devel@lists.lustre.org" class=3D"">lustre-devel@lists.lustre.o=
rg</a>&gt; wrote:<br class=3D"">
<div>
<blockquote type=3D"cite" class=3D""><br class=3D"x_Apple-interchange-newli=
ne">
<div class=3D"">
<div dir=3D"ltr" class=3D"">Hello,<br class=3D"">
<br class=3D"">
I hope this email finds you well.<br class=3D"">
<br class=3D"">
My name is Saisha, and I am currently pursuing my Ph.D. at UNC-Charlotte, w=
ith a focus on research related to the Lustre File System. As part of my pr=
oject, I am exploring the possibility of utilizing checksums to verify Lust=
re extended attributes.<br class=3D"">
<br class=3D"">
My understanding is that the ext4 file system supports checksums for extend=
ed attributes (xattrs). However, I am interested in whether this functional=
ity extends to Lustre as well.<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
Yes, the ext4 (and ZFS) xattr values have checksums. &nbsp;No, the xattr ch=
ecksums are neither managed or verified by Lustre, and only come into effec=
t when they are passed on to the backing filesystem. &nbsp;Conceivably, it =
would be possible to have a checksum (e.g.
 crc32c) for the xattr values in the MDS_GETXATTR and MDS_SETXATTR RPCs, if=
 this is something you are interested to contribute.</div>
<div><br class=3D"">
</div>
<div>This could probably be done by overloading one of the 32-bit fields in=
 the mdt_body for getxattr, and one in mdt_rec_reint for setxattr, but ther=
e is also &quot;opportunistic&quot; xattr prefetching done in the lookup RP=
C, so that would need to be covered as well.</div>
<div><br class=3D"">
</div>
<div>Also, the checksum would also need to be kept with the xattrs in cache=
 and verified on access, otherwise they could become corrupted in memory af=
ter the RPC processing had completed.</div>
<div><br class=3D"">
</div>
<div>Finally, there is no interface to specify or verify the xattr checksum=
 in the syscall interface, so there can be no guarantee that the data suppl=
ied in the setxattr is correct, or remains correct after supplied to getxat=
tr, but the window there is very
 small.</div>
<div><br class=3D"">
</div>
<div>Cheers, Andreas</div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div dir=3D"ltr" class=3D"">I would greatly appreciate it if you could prov=
ide some insights or direct me to relevant documentation on this matter. An=
y information or guidance you can offer would be invaluable to my research.=
<br class=3D"">
<br class=3D"">
Thank you very much for your time and assistance.
<div class=3D""><br class=3D"">
</div>
<div class=3D"">Thanks and Regards,</div>
<div class=3D"">Saisha</div>
</div>
_______________________________________________<br class=3D"">
lustre-devel mailing list<br class=3D"">
<a href=3D"mailto:lustre-devel@lists.lustre.org" class=3D"">lustre-devel@li=
sts.lustre.org</a><br class=3D"">
<a href=3D"https://urldefense.com/v3/__http://lists.lustre.org/listinfo.cgi=
/lustre-devel-lustre.org__;!!ACWV5N9M2RV99hQ!NxZsGb9nGU3ZLJa1pn9PclSTh2QUuT=
OnSdBLFvT4cYZxHl-jq2z3TrARWnu9vlkaS-diipwr7e73a1J0pgTw4Htt05quzd0a$">http:/=
/lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org</a><br class=3D"">
</div>
</blockquote>
</div>
<br class=3D"">
<div class=3D"">
<div dir=3D"auto" class=3D"" style=3D"color:rgb(0,0,0); letter-spacing:norm=
al; text-align:start; text-indent:0px; text-transform:none; white-space:nor=
mal; word-spacing:0px; text-decoration:none; word-wrap:break-word; line-bre=
ak:after-white-space">
<div dir=3D"auto" class=3D"" style=3D"color:rgb(0,0,0); letter-spacing:norm=
al; text-align:start; text-indent:0px; text-transform:none; white-space:nor=
mal; word-spacing:0px; text-decoration:none; word-wrap:break-word; line-bre=
ak:after-white-space">
<div dir=3D"auto" class=3D"" style=3D"color:rgb(0,0,0); letter-spacing:norm=
al; text-align:start; text-indent:0px; text-transform:none; white-space:nor=
mal; word-spacing:0px; text-decoration:none; word-wrap:break-word; line-bre=
ak:after-white-space">
<div dir=3D"auto" class=3D"" style=3D"color:rgb(0,0,0); letter-spacing:norm=
al; text-align:start; text-indent:0px; text-transform:none; white-space:nor=
mal; word-spacing:0px; text-decoration:none; word-wrap:break-word; line-bre=
ak:after-white-space">
<div dir=3D"auto" class=3D"" style=3D"color:rgb(0,0,0); letter-spacing:norm=
al; text-align:start; text-indent:0px; text-transform:none; white-space:nor=
mal; word-spacing:0px; text-decoration:none; word-wrap:break-word; line-bre=
ak:after-white-space">
<div dir=3D"auto" class=3D"" style=3D"color:rgb(0,0,0); letter-spacing:norm=
al; text-align:start; text-indent:0px; text-transform:none; white-space:nor=
mal; word-spacing:0px; text-decoration:none; word-wrap:break-word; line-bre=
ak:after-white-space">
<div>Cheers, Andreas</div>
<div>--</div>
<div>Andreas Dilger</div>
<div>Lustre&nbsp;Principal Architect</div>
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
<br class=3D"x_Apple-interchange-newline">
</div>
<br class=3D"x_Apple-interchange-newline">
<br class=3D"x_Apple-interchange-newline">
</div>
<br class=3D"">
</div>
</body>
</html>

--_000_SN6PR10MB2813B942D02E953B1786419899C02SN6PR10MB2813namp_--

--===============5240547036403182670==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============5240547036403182670==--
