From: Josephine Palencia <josephin@psc.edu>
Date: Tue, 8 Jul 2008 15:21:01 -0400 (EDT)
Subject: [Lustre-devel] GSS cross-realm on MDT -> OST
In-Reply-To: <4873A38C.4040507@sun.com>
References: <48728D97.1020704@psc.edu> <4873A38C.4040507@sun.com>
Message-ID: <Pine.LNX.4.64.0807081508040.19329@pscuxa.psc.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Tue, 8 Jul 2008, Eric Mei wrote:

> Hi Ben,
>
> Benjamin Bennett wrote:
>> Hi Eric,
>>
>>   If you could give me your input on something I'd greatly appreciate
>> it.  Or, if I should just sent this to -devel let me know...
>
> Yes you can always send to -devel for open discussions. I'm CCing it.
>
>>   For Lustre-WAN across TeraGrid we were hoping to distribute OSSs
>> across several resource providers (sites), leveraging existing kerberos
>> infrastructure, placing OSSs in each resource provider's local kerberos
>> realm, and the MDS in the teragrid realm.  Unfortunately, MDT -> OST
>> connections will not allow the MDT and OST to be in different realms,
>> since an OSS considers an MDS to be anyone holding a lustre_mds
>> principal in their local realm.
>>
>>   This also seems undesirable within a single-realm where multiple
>> lustre clusters may exist, as an OSS in cluster A will trust an MDS for
>> cluster B, and an OSS for cluster B will trust an MDS for cluster A.
>>
>>   My first thought was to add functionality to tell the OSSs lsvcgssd
>> what the trusted MDS principals should be (local or not).  Do you have
>> any thoughts on this?
>
> We just never thought the usage that OSS could locate in multiple
> realms. I agree with you in this case, we can make OSS configurable to
> only accept designated lustre_mds principals, local or remote.
>
> I'v questions just for curiosity: 1) is the benefit of cross site OSSs
> about bandwidth? 2) in the future with CMD (clustered metadata, multiple
> MDS nodes), would it be useful to distribute MDSs across multiple site
> as well?


At this point, we only want to be able to test functionality, i.e. 
create a lustre fs over the WAN with OSS contributions from  various remote RP 
remote while kerb auth is enabled.  Eventually one will have to deal with 
performance issues due to the setup but hopefully when that time comes, 
other  mechanisms will become possible (distributed MDS) to manage the 
remote OSS's.


Thanks,
-j

>
> Thanks
> -- 
> Eric
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>
