def removeDuplicates(nums):
    if not nums:
        return 0
    
    i = 0  # pointer for unique elements
    for j in range(1, len(nums)):
        if nums[j] != nums[i]:
            i += 1
            nums[i] = nums[j]
    return i + 1

# --- main program ---
# Taking input from user
nums = list(map(int, input("Enter numbers separated by space: ").split()))

# Calling the function
k = removeDuplicates(nums)

# Printing result
print("New length:", k)
print("Array after removing duplicates:", nums[:k])
