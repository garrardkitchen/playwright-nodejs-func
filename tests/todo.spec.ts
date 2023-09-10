import { test, expect } from "@playwright/test"
import { v4 as uuidv4 } from "uuid"

test("Check heading contains Welcome", async ({ page }) => {
  await page.goto("/", { waitUntil: 'networkidle' })
  await expect(page.getByRole('heading', { name: 'Welcome' })).toHaveText('Welcome')
})
