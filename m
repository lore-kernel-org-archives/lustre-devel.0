From: Yong Fan <Yong.Fan@Sun.COM>
Date: Tue, 10 Jun 2008 00:09:33 +0800
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <C472AA74.597C%peter.braam@sun.com>
References: <C472AA74.597C%peter.braam@sun.com>
Message-ID: <484D55BD.2010806@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam ??:
> Thanks for explaining.
>
> The trust concept you outline is definitely not acceptable - we need a
> capability for all access and modifications done through clients on behalf
> of a capability.
>
> Even changes made by the MDS need to be secured - that can be through a
> kerberos connection, and again, not through blind trust.
>   
The client reliability (trusted or untrusted) and the MDS/OSS capabilities
are not conflict. They can be combined together as mentioned in draft of
new MDS/OSS capabilities HLD.

capabilities.lyx is the old HLD
capability_hld.lyx is the new HLD which is in patch inspection and fix.


Thanks!
--
Fan Yong
> Would you please send the capability HLD to me?  Thanks!
>
> - Peter -
>
>
> On 6/9/08 2:52 AM, "Yong Fan" <Yong.Fan@Sun.COM> wrote:
>
>   
>> Peter Braam ??:
>>     
>>> On 6/6/08 1:33 AM, "Johann Lombardi" <johann@sun.com> wrote:
>>>
>>>   
>>>       
>>>> On Thu, Jun 05, 2008 at 06:45:36AM -0700, Peter Braam wrote:
>>>>     
>>>>         
>>>>> Well, this protocol hasn't been published yet; why not include the server
>>>>> side uid / gid then?
>>>>>       
>>>>>           
>>>> I understood from Fanyong that according to the remote client design
>>>> requirements, we should not allow the remote client to access the
>>>> server-side
>>>> uid/gid mapping.
>>>>     
>>>>         
>>> You have two choices: break that rule OR let the MDS server do the ownership
>>> changes.  It's not complicated, just make a choice.
>>>
>>>   
>>>       
>>>>> But more seriously, how is this encoded in such a way that the OST can
>>>>> trust
>>>>> the information - it must be in the capability too?
>>>>>       
>>>>>           
>>>> hmm, I don't see any capability associated with this.
>>>>     
>>>>         
>>> We had better find it, otherwise there is a security hole.
>>>
>>>
>>>   
>>>       
>> I think we can divide clients into two sorts: trusted and untrusted.
>> The client reliability is defined by administrator. Remote client
>> should be counted as untrusted one. The best simple way is that:
>> local client is trusted, remote client is untrusted.
>>
>> For the trusted ones, disable capability, OSS set file "uid" and "gid"
>> with "oa.o_uid" and "oa.o_gid". It is the current using means.
>> For the untrusted ones, enable capability, OSS set file "uid" and "gid"
>> which contain in the OSS capability got from MDS when open.
>> With OSS capability enabled will affect performance, and current
>> capability's design does not contain the consideration for that. We
>> can fix the OSS capability design in the task "o3_se_capa_review"
>>
>> Note: since capability feature is time-consuming, we want to support
>> enforcing capabilities on selected clients (or somewhat MDS/OSS
>> capability should aim at remote client). On he other hand, enforcing
>> capabilities on selected clients can simply the capability interoperability
>> between HEAD and b1_6.
>>
>> If this idea can be approved, then the current remote client uid mapping
>> rules can be unchanged, uid mapping on OST is unnecessary also.
>>
>>
>> Thanks!
>> --
>> Fan Yong
>>     
>>>> Johann
>>>> _______________________________________________
>>>> Lustre-devel mailing list
>>>> Lustre-devel at lists.lustre.org
>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>>     
>>>>         
>>>   
>>>       
>
>
>   

-------------- next part --------------
A non-text attachment was scrubbed...
Name: capabilities.lyx
Type: application/x-lyx
Size: 8268 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080610/c0ee7ff3/attachment.lyx>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: capability_hld.lyx
Type: application/x-lyx
Size: 20857 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080610/c0ee7ff3/attachment-0001.lyx>
