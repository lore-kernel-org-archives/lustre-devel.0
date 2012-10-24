From: Colin Faber <cfaber@gmail.com>
Date: Wed, 24 Oct 2012 16:09:43 -0600
Subject: [Lustre-devel] Language choice for Lustre tests
In-Reply-To: <BF3E1573-A1E3-47DF-B1B1-866EB65A0D49@xyratex.com>
References: <EA3A770421F31B4BB895DD3AB9224495706F0E@fmsmsx119.amr.corp.intel.com>
	<BF3E1573-A1E3-47DF-B1B1-866EB65A0D49@xyratex.com>
Message-ID: <50886727.9010307@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

My vote here is perl, there's a few [lustre] tools already written in 
perl, it also meets all of the stated requirements. Yes, perl can look 
like core dump. Yes perl can be easily obfuscated and impossibly hard to 
understand (even for expert class developers). However the enormous 
range of module support, as well as the maturity and cross platform 
portability make it ideal for this task.

-cf

On 10/24/2012 04:05 PM, Nathan Rutman wrote:
>
> On Oct 24, 2012, at 1:02 PM, "Gearing, Chris" <chris.gearing@intel.com 
> <mailto:chris.gearing@intel.com>> wrote:
>
>> Nathan,
>>
>> I'm not 100% sure what you are proposing here, your LAD presentation 
>> suggested a 'tune-up' of the current test framework rather than a 
>> complete re-write. Which of the two are we discussing?
> Both...
>>
>> Which ever you are intending to undertake I think it is vital that 
>> before decisions are made on things such as languages a clear 
>> specification/definition of the activity is created and distributed. 
>> I am in fact working with Roman to bring such a document to the 
>> working group on the tune-up, making me somewhat confused about what 
>> is proposed here.
>>
>> Going back to your LAD presentation for the tune-up your intention is 
>> to write some libraries to better address the requirements of the 
>> framework than is possible in bash, but those libraries would be 
>> called from the existing bash tests. This illustrates that the 
>> language used to develop the framework may not be the same language 
>> used for writing the tests, in fact I'm guessing that for both a 
>> tune-up and rewrite the requirements placed on the framework writer 
>> are different than those place on the test writer and so the 
>> languages required might well be different,
>> and in fact if this is a tune-up then surely the tests must continue 
>> to be written in bash even if the libraries are in something more 
>> applicable, we do not want a single framework with mixed languages 
>> (do we?)
>
> The ultimate goal is to produce higher-quality, more robust, 
> well-controlled, and safer tests.  To that end, I think the eventual 
> language of the tests must change to something meeting the 
> requirements I stated before:
> 1. easy to use
> 2. strict structure
> 3. universally available/portable
> 4. widely maintained
> 5. widely understood
> 6. fully-featured filesystem interface: posix API
> 7. fast - replace e.g. createmany with embedded function
> 8. operate remote instances
> 9. inter-version compatibility
> The requirements on the framework language are more relaxed, but for 
> ease of development and developer sanity, I assume that the framework 
> language should match the test language.  So I'm using the test 
> language as the requirements driver, and to gage community preference 
> for that test language.
>
> Based on the responses so far, it seems that there is a fairly clear 
> preference for Python as a test language, and so I'll propose that 
> Python should be used shorter-term to start replacing test-framework.
>
>
>> So to return to my original question could you please provide some 
>> greater depth of insight as to what you are embarking upon, and then 
>> we can make more objective input as the language required.
>>
>> On the complete-rewrite topic, I will post the slides I sent you 
>> before LAD to the Whamcloud wiki and then provide a link to this list 
>> so that people can share our thoughts. (Network access prevents me 
>> doing this immediately)
>>
>> Regards
>>
>> Chris
>> ---------------------------------------------------------------------
>> Intel Corporation (UK) Limited
>> Registered No. 1134945 (England)
>> Registered Office: Pipers Way, Swindon SN3 1RJ
>> VAT No: 860 2173 47
>>
>> This e-mail and any attachments may contain confidential material for
>> the sole use of the intended recipient(s). Any review or distribution
>> by others is strictly prohibited. If you are not the intended
>> recipient, please contact the sender and delete all copies.
>>
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org <mailto:Lustre-devel@lists.lustre.org>
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
