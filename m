From: Jacques-Charles Lafoucriere <jc.lafoucriere@cea.fr>
Date: Fri, 11 Jul 2008 16:32:48 +0200
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <C49A1E05.4E85%peter.braam@sun.com>
References: <C49A1E05.4E85%peter.braam@sun.com>
Message-ID: <48776F10.60008@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



Peter Braam wrote:
>>> 3. how are multiple coordinators and agents utilized to distribute load so
>>> that the HSM can keep up with massive small file creation?
>>>       
>> One coordinator per MDT.
>>     
>
> No - these must be independent considerations.  A coordinator may be much
> slower than an MDS node in handling a single file.  I say this because this
> has been the experience in the industry so far - with small files the HSM
> can not at all keep up.
>   

Why a coordinator should be on a slower node than a MDS ?
Coordinator is a Lustre service  like other Lustre services so it will 
be on a right hardware

Do you mean a coordinator is not part of the Lustre cluster ?

JC
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080711/506825c7/attachment.htm>
